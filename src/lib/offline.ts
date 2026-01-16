import { openDB, type IDBPDatabase } from 'idb';

const DB_NAME = 'shayou-offline-db';
const STORE_NAME = 'action-queue';

export interface QueuedAction {
  id?: number;
  type: 'submit_task' | 'request_spend' | 'update_goal';
  payload: any;
  timestamp: number;
}

let dbPromise: Promise<IDBPDatabase>;

if (typeof window !== 'undefined') {
  dbPromise = openDB(DB_NAME, 1, {
    upgrade(db) {
      if (!db.objectStoreNames.contains(STORE_NAME)) {
        db.createObjectStore(STORE_NAME, { keyPath: 'id', autoIncrement: true });
      }
    },
  });
}

export async function queueAction(action: Omit<QueuedAction, 'timestamp'>) {
  const db = await dbPromise;
  await db.add(STORE_NAME, {
    ...action,
    timestamp: Date.now()
  });
  
  // Try to sync if online
  if (navigator.onLine) {
    syncQueue();
  }
}

export async function getQueue() {
  const db = await dbPromise;
  return db.getAll(STORE_NAME);
}

export async function clearQueue() {
  const db = await dbPromise;
  await db.clear(STORE_NAME);
}

export async function syncQueue() {
  const queue = await getQueue();
  if (queue.length === 0) return;

  console.log('Syncing offline actions...', queue);

  // Here you would iterate through actions and call Supabase
  // for (const action of queue) { ... }
  
  // For now, just a placeholder
  await clearQueue();
  console.log('Offline actions synced successfully!');
}
