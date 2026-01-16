<!-- Page: Parent Settings -->
<script lang="ts">
  import { Settings, User, Bell, Shield, LogOut, ChevronRight, Palette } from 'lucide-svelte';
  import { fade } from 'svelte/transition';
  import { goto } from '$app/navigation';

  const menuItems = [
    { icon: User, label: 'Profile Details', color: 'blue' },
    { icon: Bell, label: 'Notifications', color: 'pink' },
    { icon: Shield, label: 'Security & Access Code', color: 'yellow' },
    { icon: Palette, label: 'App Theme', color: 'red' }
  ];

  function handleLogout() {
    // Clear session data
    localStorage.removeItem('family_id');
    // Go back to login
    goto('/login');
  }
</script>

<div class="space-y-6" in:fade>
  <header class="bg-white p-8 rounded-[2.5rem] shadow-sm text-center border-b-4 border-yellow-200">
    <div class="w-24 h-24 bg-blue-100 rounded-[2rem] mx-auto mb-4 flex items-center justify-center text-blue-500 shadow-inner">
      <Settings size={48} />
    </div>
    <h1 class="text-3xl font-black text-gray-900">Settings</h1>
    <p class="text-gray-400 font-bold italic">Manage your family account</p>
  </header>

  <div class="bg-white rounded-[2.5rem] shadow-sm overflow-hidden border border-gray-100">
    {#each menuItems as item, i}
      <button class="w-full flex items-center justify-between p-6 hover:bg-gray-50 transition-colors border-b border-gray-50 last:border-0 group">
        <div class="flex items-center gap-4">
          <div class="p-3 rounded-2xl bg-{item.color}-50 text-{item.color}-500 group-hover:scale-110 transition-transform">
            <item.icon size={24} />
          </div>
          <span class="font-black text-gray-700 text-lg">{item.label}</span>
        </div>
        <ChevronRight size={20} class="text-gray-300 group-hover:text-gray-500 transition-colors" />
      </button>
    {/each}
  </div>

  <button onclick={handleLogout} class="w-full bg-red-50 text-red-500 py-6 rounded-[2rem] font-black flex items-center justify-center gap-3 border-2 border-red-100 hover:bg-red-500 hover:text-white transition-all active:scale-95 shadow-lg shadow-red-50 mb-10">
    <LogOut size={24} /> Sign Out
  </button>
</div>
