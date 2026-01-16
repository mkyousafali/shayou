<!-- Page: Kid Home -->
<script lang="ts">
  import { Wallet, Target, CheckCircle, ArrowRight, Gamepad2, Brain, Sparkles, Loader2, LogOut } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';
  import { page } from '$app/state';
  import { goto } from '$app/navigation';

  let loading = $state(true);
  let kidId = page.params.kidId;
  let kid = $state(null);
  let tasks = $state<any[]>([]);
  let progress = $state(65);
  let goalName = $state('Gaming Console');

  onMount(async () => {
    await fetchKidData();
  });

  async function fetchKidData() {
    loading = true;
    try {
      // Fetch Kid Info
      const { data: kidData, error: kidError } = await supabase
        .from('kids')
        .select('*')
        .eq('id', kidId)
        .single();
      
      if (kidError) throw kidError;
      kid = kidData;

      // Fetch Tasks
      const { data: tasksData, error: tasksError } = await supabase
        .from('tasks')
        .select('*')
        .eq('kid_id', kidId)
        .order('created_at', { ascending: false })
        .limit(3);
      
      if (!tasksError) tasks = tasksData || [];

    } catch (e) {
      console.error('Error fetching kid data:', e);
    } finally {
      loading = false;
    }
  }

  function handleLogout() {
    // Clear session data
    localStorage.removeItem('kid_id');
    localStorage.removeItem('family_id');
    // Go back to login
    goto('/kid/login');
  }
</script>

<div class="space-y-8 pb-20" in:fade>
  {#if loading || !kid}
    <div class="flex flex-col items-center justify-center py-20 gap-4 text-blue-500">
      <Loader2 size={64} class="animate-spin" />
      <p class="text-2xl font-black italic tracking-tight">Waking up your world... ✨</p>
    </div>
  {:else}
    <!-- Header with Logout Button -->
    <div class="flex justify-between items-center mb-4">
      <h1 class="text-3xl font-black text-gray-900">Welcome, {kid.name}! 👋</h1>
      <button
        onclick={handleLogout}
        class="flex items-center gap-2 bg-red-50 text-red-600 px-4 py-2 rounded-2xl font-bold hover:bg-red-100 transition-all active:scale-95"
        title="Log out"
      >
        <LogOut size={20} />
        <span class="text-sm">Logout</span>
      </button>
    </div>

    <!-- Hero Wallet Card -->
    <section class="relative overflow-hidden rounded-[3.5rem] bg-gradient-to-br from-blue-500 via-blue-600 to-indigo-600 p-10 text-white shadow-2xl shadow-blue-100 uppercase italic">
      <div class="relative z-10 flex justify-between items-center">
        <div>
          <p class="text-blue-100 text-lg font-black tracking-widest">My Treasure</p>
          <h1 class="text-6xl font-black mt-2">🪙 {kid.balance}</h1>
          <div class="mt-6 flex items-center gap-2 bg-white/20 backdrop-blur-md px-4 py-2 rounded-2xl border border-white/30 w-fit">
            <Sparkles size={20} class="text-yellow-400" />
            <span class="font-black text-sm">Level: Master Explorer</span>
          </div>
        </div>
        <div class="bg-white/20 p-6 rounded-[2rem] backdrop-blur-xl shadow-inner rotate-3">
          <Wallet size={64} />
        </div>
      </div>
      <div class="absolute -top-12 -right-12 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
      <div class="absolute -bottom-12 -left-12 w-64 h-64 bg-yellow-400/20 rounded-full blur-3xl"></div>
    </section>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
      <!-- Today's Tasks -->
      <div class="bg-white rounded-[3rem] p-8 shadow-xl border-b-[12px] border-blue-400">
        <div class="flex justify-between items-center mb-8">
          <h2 class="text-3xl font-black text-gray-900 tracking-tight italic">Missions</h2>
          <a href="/kid/{kidId}/tasks" class="bg-blue-50 text-blue-500 p-2 rounded-2xl">
            <ArrowRight size={24} />
          </a>
        </div>
        <div class="space-y-4">
          {#each tasks as task}
            <div class="flex items-center justify-between p-5 bg-gray-50 rounded-[2rem] border-2 border-transparent transition-all">
              <div class="flex items-center gap-4">
                <div class="bg-white p-3 rounded-2xl shadow-sm text-blue-500">
                  <CheckCircle size={24} class={task.status === 'completed' ? 'fill-blue-500 text-white' : ''} />
                </div>
                <div>
                  <p class="font-black text-gray-800 text-lg {task.status === 'completed' ? 'line-through opacity-50' : ''}">{task.title}</p>
                  <p class="text-yellow-600 font-black">🪙 {task.reward}</p>
                </div>
              </div>
            </div>
          {:else}
            <p class="text-center text-gray-400 font-bold py-4">No missions yet. Ask your parents! 😊</p>
          {/each}
        </div>
      </div>

      <!-- Habit Adventure Tile -->
      <div class="bg-pink-500 rounded-[3rem] p-8 text-white shadow-xl shadow-pink-100 flex flex-col justify-between border-b-[12px] border-pink-700 relative overflow-hidden group">
        <div class="relative z-10">
          <div class="bg-white/20 w-fit p-4 rounded-[1.5rem] mb-6 shadow-inner group-hover:rotate-12 transition-transform">
            <Gamepad2 size={40} />
          </div>
          <h2 class="text-3xl font-black mb-2 tracking-tight">Habit World</h2>
          <p class="font-bold opacity-90 text-lg">Play games and master good habits! 🎮</p>
        </div>
        <a href="/kid/1/habits" class="relative z-10 mt-8 bg-white text-pink-500 font-black py-5 rounded-[2rem] text-center text-xl shadow-lg active:scale-95 transition-all">
          Start Adventure
        </a>
        <div class="absolute -right-10 -top-10 opacity-10 rotate-12">
          <Brain size={200} />
        </div>
      </div>
    </div>

    <!-- Goal Progress -->
    <div class="bg-white rounded-[4rem] p-10 shadow-xl border-2 border-gray-50 flex flex-col md:flex-row items-center gap-10">
      <div class="relative w-48 h-48">
        <svg class="w-full h-full" viewBox="0 0 100 100">
          <circle cx="50" cy="50" r="45" fill="none" stroke="#f3f4f6" stroke-width="10" />
          <circle cx="50" cy="50" r="45" fill="none" stroke="#facc15" stroke-width="10" 
                  stroke-dasharray="282.7" stroke-dashoffset={282.7 * (1 - progress / 100)}
                  stroke-linecap="round" class="transition-all duration-1000 ease-out shadow-lg" />
        </svg>
        <div class="absolute inset-0 flex flex-col items-center justify-center">
          <span class="text-4xl font-black text-gray-900">{progress}%</span>
        </div>
      </div>
      <div class="flex-1 space-y-4 text-center md:text-left">
        <h3 class="text-3xl font-black text-gray-900">Next Big Prize: {goalName}</h3>
        <p class="text-xl text-gray-400 font-bold italic">Keep up the great habits, you're almost there! 🌟</p>
        <div class="bg-yellow-50 text-yellow-700 px-6 py-3 rounded-2xl w-fit mx-auto md:mx-0 font-black border border-yellow-100">
          Need 🪙 350 more
        </div>
      </div>
    </div>
  {/if}
</div>

