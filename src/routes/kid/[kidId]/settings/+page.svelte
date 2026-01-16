<!-- Page: Kid Settings -->
<script lang="ts">
  import { User, Palette, LogOut, ChevronRight, Sparkles, Music, Ghost } from 'lucide-svelte';
  import { fade } from 'svelte/transition';

  const items = [
    { icon: Ghost, label: 'Change My Avatar', color: 'blue' },
    { icon: Palette, label: 'Pick My Colors', color: 'pink' },
    { icon: Music, label: 'Sound Effects', color: 'yellow' },
    { icon: Sparkles, label: 'App Theme', color: 'red' }
  ];
</script>

<div class="space-y-6 pb-24" in:fade>
  <header class="text-center py-8">
    <div class="w-28 h-28 bg-blue-500 rounded-full mx-auto mb-4 border-8 border-white shadow-xl flex items-center justify-center text-white text-4xl font-black">
      L
    </div>
    <h1 class="text-3xl font-black text-gray-900">My Profile</h1>
    <p class="text-blue-500 font-bold italic">Make the app your own! ✨</p>
  </header>

  <div class="space-y-3 px-2">
    {#each items as item}
      <button class="w-full bg-white p-6 rounded-[2.5rem] shadow-sm flex items-center justify-between border-b-4 border-gray-100 active:translate-y-1 active:border-b-0 transition-all group">
        <div class="flex items-center gap-4">
          <div class="p-4 rounded-3xl bg-{item.color}-100 text-{item.color}-500 group-hover:rotate-6 transition-transform">
            <item.icon size={28} />
          </div>
          <span class="text-xl font-black text-gray-800">{item.label}</span>
        </div>
        <ChevronRight size={24} class="text-gray-300" />
      </button>
    {/each}
  </div>

  <button class="w-full mt-10 p-6 rounded-[2.5rem] bg-gray-100 text-gray-500 font-black flex items-center justify-center gap-2 hover:bg-red-50 hover:text-red-500 transition-all">
    <LogOut size={24} /> Logout
  </button>
</div>
