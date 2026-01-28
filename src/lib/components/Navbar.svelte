<script lang="ts">
  import { Shield, Home, CheckCircle, Target, Wallet, Settings } from 'lucide-svelte';
  import { page } from '$app/state';

  let isParent = $derived(page.url.pathname.startsWith('/parent'));
  let kidId = $derived(page.params.kidId);
</script>

<nav class="fixed bottom-0 left-0 right-0 glass border-t border-gray-200 px-2 sm:px-4 py-2 sm:py-3 flex justify-around items-center gap-1 sm:gap-2 z-50">
  {#if isParent}
    <a href="/parent/dashboard" class="flex flex-col items-center gap-0.5 sm:gap-1 text-gray-600 hover:text-blue-600 py-1 px-2 rounded-lg transition-colors">
      <Home size={20} className="sm:w-6 sm:h-6" />
      <span class="text-[8px] sm:text-[10px]">Home</span>
    </a>
    <a href="/parent/tasks" class="flex flex-col items-center gap-0.5 sm:gap-1 text-gray-600 hover:text-blue-600 py-1 px-2 rounded-lg transition-colors">
      <CheckCircle size={20} className="sm:w-6 sm:h-6" />
      <span class="text-[8px] sm:text-[10px]">Tasks</span>
    </a>
    <a href="/parent/kids" class="flex flex-col items-center gap-0.5 sm:gap-1 text-gray-600 hover:text-blue-600 py-1 px-2 rounded-lg transition-colors">
      <Shield size={20} className="sm:w-6 sm:h-6" />
      <span class="text-[8px] sm:text-[10px]">Kids</span>
    </a>
    <a href="/parent/settings" class="flex flex-col items-center gap-0.5 sm:gap-1 text-gray-600 hover:text-blue-600 py-1 px-2 rounded-lg transition-colors">
      <Settings size={20} className="sm:w-6 sm:h-6" />
      <span class="text-[8px] sm:text-[10px]">Settings</span>
    </a>
  {:else if kidId}
    <a href="/kid/{kidId}/home" class="flex flex-col items-center gap-0.5 sm:gap-1 text-gray-600 hover:text-blue-500 py-1 px-2 rounded-lg transition-colors">
      <Home size={20} className="sm:w-6 sm:h-6" />
      <span class="text-[8px] sm:text-[10px]">Home</span>
    </a>
    <a href="/kid/{kidId}/tasks" class="flex flex-col items-center gap-0.5 sm:gap-1 text-gray-600 hover:text-pink-500 py-1 px-2 rounded-lg transition-colors">
      <CheckCircle size={20} className="sm:w-6 sm:h-6" />
      <span class="text-[8px] sm:text-[10px]">Tasks</span>
    </a>
    <a href="/kid/{kidId}/goals" class="flex flex-col items-center gap-0.5 sm:gap-1 text-gray-600 hover:text-yellow-500 py-1 px-2 rounded-lg transition-colors">
      <Target size={20} className="sm:w-6 sm:h-6" />
      <span class="text-[8px] sm:text-[10px]">Goals</span>
    </a>
    <a href="/kid/{kidId}/wallet" class="flex flex-col items-center gap-0.5 sm:gap-1 text-gray-600 hover:text-red-500 py-1 px-2 rounded-lg transition-colors">
      <Wallet size={20} className="sm:w-6 sm:h-6" />
      <span class="text-[8px] sm:text-[10px]">Wallet</span>
    </a>
  {/if}
</nav>
