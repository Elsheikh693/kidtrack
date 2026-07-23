/**
 * Backfill `branchId` on classroom-scoped content so shared (isAllBranches)
 * classrooms stop leaking activities / photos / homework / sessions across
 * branches. The branch is derived from the record's creator:
 *
 *   classroomActivities/{cid}/{aid}.branchId  <- staff[teacherId].branchId
 *   sessions/{sid}.branchId                   <- staff[teacherId].branchId
 *   homework/{hid}.branchId                   <- staff[createdBy|teacherId].branchId
 *
 * SAFETY
 *   • DRY RUN by default — prints every change it *would* make. Pass --apply to write.
 *   • Only ever ADDS a `branchId` field. Never deletes or overwrites any other data.
 *   • Idempotent: records that already have a non-empty branchId are skipped.
 *   • Records whose creator can't be resolved to a branch are left untouched and
 *     listed under "unresolved" so nothing is guessed.
 *
 * USAGE
 *   cd functions
 *   # dry run, sunny bunny only (default):
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json \
 *     node scripts/backfill_branch_ids.js
 *   # apply to sunny bunny:
 *   GOOGLE_APPLICATION_CREDENTIALS=... node scripts/backfill_branch_ids.js --apply
 *   # a different nursery / all nurseries:
 *   node scripts/backfill_branch_ids.js --nursery=<nurseryId>
 *   node scripts/backfill_branch_ids.js --all --apply
 *
 * ENV
 *   GOOGLE_APPLICATION_CREDENTIALS  path to a service-account key with RTDB access
 *   DATABASE_URL                    RTDB url (default below)
 */

'use strict';

const admin = require('firebase-admin');
const fs = require('fs');

const DATABASE_URL =
  process.env.DATABASE_URL ||
  'https://kidtrack-bed28-default-rtdb.firebaseio.com';

// sunny bunny — the nursery this backfill was written for.
const DEFAULT_NURSERY = 'ef830294-7b0d-4710-9fc1-a92ce667bbde';

const args = process.argv.slice(2);
const APPLY = args.includes('--apply');
const ALL = args.includes('--all');
const nurseryArg = (args.find((a) => a.startsWith('--nursery=')) || '').split('=')[1];

// Preflight: fail fast with a clear message instead of the SDK's endless
// invalid-credential retry loop. A key path can come from GOOGLE_APPLICATION_-
// CREDENTIALS or `--key=/abs/path.json`.
const keyArg = (args.find((a) => a.startsWith('--key=')) || '').split('=')[1];
const keyPath = keyArg || process.env.GOOGLE_APPLICATION_CREDENTIALS;
if (!keyPath) {
  console.error(
    'No credentials. Generate a service-account key and pass it, e.g.:\n' +
      '  node scripts/backfill_branch_ids.js --key=/absolute/path/serviceAccount.json\n' +
      'or:  GOOGLE_APPLICATION_CREDENTIALS=/abs/path.json node scripts/backfill_branch_ids.js\n' +
      'Get the key: Firebase Console → Project settings → Service accounts → Generate new private key.'
  );
  process.exit(1);
}
if (!fs.existsSync(keyPath)) {
  console.error(`Credential file not found: ${keyPath}`);
  console.error('(You passed the placeholder path — replace it with the real key file.)');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require(keyPath)),
  databaseURL: DATABASE_URL,
});
const db = admin.database();

function branchOf(staff, uid) {
  if (!uid) return '';
  const s = staff && staff[uid];
  if (!s) return '';
  const b = s.branchId;
  return typeof b === 'string' ? b : '';
}

// Collect { path -> branchId } updates for one nursery.
function planNursery(nid, node) {
  const staff = node.staff || {};
  const updates = {};
  const stats = {
    activities: { stamped: 0, already: 0, unresolved: 0 },
    sessions: { stamped: 0, already: 0, unresolved: 0 },
    homework: { stamped: 0, already: 0, unresolved: 0 },
  };
  const unresolved = [];

  const has = (v) => typeof v === 'string' && v.length > 0;

  // classroomActivities/{cid}/{aid}
  const ca = node.classroomActivities || {};
  for (const cid of Object.keys(ca)) {
    const acts = ca[cid] || {};
    for (const aid of Object.keys(acts)) {
      const a = acts[aid];
      if (!a || typeof a !== 'object') continue;
      if (has(a.branchId)) { stats.activities.already++; continue; }
      const b = branchOf(staff, a.teacherId);
      if (!b) {
        stats.activities.unresolved++;
        unresolved.push(`activity ${cid}/${aid} teacher=${a.teacherId || '-'}`);
        continue;
      }
      updates[`platform/${nid}/classroomActivities/${cid}/${aid}/branchId`] = b;
      stats.activities.stamped++;
    }
  }

  // sessions/{sid}
  const sessions = node.sessions || {};
  for (const sid of Object.keys(sessions)) {
    const s = sessions[sid];
    if (!s || typeof s !== 'object') continue;
    if (has(s.branchId)) { stats.sessions.already++; continue; }
    const b = branchOf(staff, s.teacherId);
    if (!b) {
      stats.sessions.unresolved++;
      unresolved.push(`session ${sid} teacher=${s.teacherId || '-'}`);
      continue;
    }
    updates[`platform/${nid}/sessions/${sid}/branchId`] = b;
    stats.sessions.stamped++;
  }

  // homework/{hid}
  const homework = node.homework || {};
  for (const hid of Object.keys(homework)) {
    const h = homework[hid];
    if (!h || typeof h !== 'object') continue;
    if (has(h.branchId)) { stats.homework.already++; continue; }
    const b = branchOf(staff, h.createdBy) || branchOf(staff, h.teacherId);
    if (!b) {
      stats.homework.unresolved++;
      unresolved.push(`homework ${hid} createdBy=${h.createdBy || '-'}`);
      continue;
    }
    updates[`platform/${nid}/homework/${hid}/branchId`] = b;
    stats.homework.stamped++;
  }

  return { updates, stats, unresolved };
}

async function chunkedUpdate(updates) {
  const keys = Object.keys(updates);
  const CHUNK = 400;
  for (let i = 0; i < keys.length; i += CHUNK) {
    const slice = {};
    for (const k of keys.slice(i, i + CHUNK)) slice[k] = updates[k];
    await db.ref().update(slice);
  }
}

async function main() {
  let nurseryIds;
  if (ALL) {
    const snap = await db.ref('platform').get();
    nurseryIds = Object.keys(snap.val() || {}).filter((k) => k !== 'info');
  } else {
    nurseryIds = [nurseryArg || DEFAULT_NURSERY];
  }

  console.log(`Mode: ${APPLY ? 'APPLY (writing)' : 'DRY RUN (no writes)'}`);
  console.log(`DB:   ${DATABASE_URL}`);
  console.log(`Nurseries: ${nurseryIds.join(', ')}\n`);

  // Nursery display names live at platform/info/{nid}/name (not under the node).
  const infoSnap = await db.ref('platform/info').get();
  const info = infoSnap.val() || {};

  let allUpdates = {};
  for (const nid of nurseryIds) {
    const snap = await db.ref(`platform/${nid}`).get();
    const node = snap.val();
    if (!node) { console.log(`  ${nid}: (empty, skipped)`); continue; }
    const { updates, stats, unresolved } = planNursery(nid, node);
    const name = (info[nid] && info[nid].name) || '';
    console.log(`── ${nid} ${name ? '(' + name + ')' : ''}`);
    console.log(
      `   activities  stamp=${stats.activities.stamped} already=${stats.activities.already} unresolved=${stats.activities.unresolved}`
    );
    console.log(
      `   sessions    stamp=${stats.sessions.stamped} already=${stats.sessions.already} unresolved=${stats.sessions.unresolved}`
    );
    console.log(
      `   homework    stamp=${stats.homework.stamped} already=${stats.homework.already} unresolved=${stats.homework.unresolved}`
    );
    if (unresolved.length) {
      console.log(`   UNRESOLVED (${unresolved.length}) — left untouched:`);
      for (const u of unresolved) console.log(`     • ${u}`);
    }
    allUpdates = Object.assign(allUpdates, updates);
  }

  const total = Object.keys(allUpdates).length;
  console.log(`\nTotal branchId writes planned: ${total}`);

  if (!APPLY) {
    console.log('DRY RUN — nothing written. Re-run with --apply to commit.');
    return;
  }
  if (total === 0) {
    console.log('Nothing to write.');
    return;
  }
  await chunkedUpdate(allUpdates);
  console.log(`Applied ${total} branchId writes.`);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('FAILED:', e);
    process.exit(1);
  });
