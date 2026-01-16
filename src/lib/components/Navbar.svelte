<script lang="ts">
  import { Shield, Home, CheckCircle, Target, Wallet, Settings } from 'lucide-svelte';
  import { page } from '$app/state';

  let isParent = $derived(page.url.pathname.startsWith('/parent'));
  let kidId = $derived(page.params.kidId);
</script>

<nav class="fixed bottom-0 left-0 right-0 glass border-t border-gray-200 px-4 py-2 flex justify-around items-center md:top-0 md:bottom-auto md:flex-col md:w-20 md:h-screen md:justify-center md:gap-8 z-50">
  {#if isParent}
    <a href="/parent/dashboard" class="flex flex-col items-center gap-1 text-gray-600 hover:text-blue-600">
      <Home size={24} />
      <span class="text-[10px] md:hidden">Home</span>
    </a>
    <a href="/parent/approvals" class="flex flex-col items-center gap-1 text-gray-600 hover:text-blue-600">
      <CheckCircle size={24} />
      <span class="text-[10px] md:hidden">Approvals</span>
    </a>
    <a href="/parent/kids" class="flex flex-col items-center gap-1 text-gray-600 hover:text-blue-600">
      <Shield size={24} />
      <span class="text-[10px] md:hidden">Kids</span>
    </a>
    <a href="/parent/settings" class="flex flex-col items-center gap-1 text-gray-600 hover:text-blue-600">
      <Settings size={24} />
      <span class="text-[10px] md:hidden">Settings</span>
    </a>
  {:else if kidId}
    <a href="/kid/{kidId}/home" class="flex flex-col items-center gap-1 text-gray-600 hover:text-blue-500">
      <Home size={24} />
      <span class="text-[10px] md:hidden">Home</span>
    </a>
    <a href="/kid/{kidId}/tasks" class="flex flex-col items-center gap-1 text-gray-600 hover:text-pink-500">
      <CheckCircle size={24} />
      <span class="text-[10px] md:hidden">Tasks</span>
    </a>
    <a href="/kid/{kidId}/goals" class="flex flex-col items-center gap-1 text-gray-600 hover:text-yellow-500">
      <Target size={24} />
      <span class="text-[10px] md:hidden">Goals</span>
    </a>
    <a href="/kid/{kidId}/wallet" class="flex flex-col items-center gap-1 text-gray-600 hover:text-red-500">
      <Wallet size={24} />
      <span class="text-[10px] md:hidden">Wallet</span>
    </a>
  {/if}
</nav>
