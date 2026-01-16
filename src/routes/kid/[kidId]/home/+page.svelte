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

<div class="space-y-4 sm:space-y-6 lg:space-y-8 pb-20" in:fade>
  {#if loading || !kid}
    <div class="flex flex-col items-center justify-center py-12 sm:py-20 gap-4 text-blue-500">
      <Loader2 size={48} sm:size={64} class="animate-spin" />
      <p class="text-lg sm:text-2xl font-black italic tracking-tight">Waking up your world... ✨</p>
    </div>
  {:else}
    <!-- Header with Logout Button -->
    <div class="flex justify-between items-center gap-2 mb-3 sm:mb-4 px-2">
      <h1 class="text-xl sm:text-2xl lg:text-3xl font-black text-gray-900">Welcome, {kid.name}! 👋</h1>
      <button
        onclick={handleLogout}
        class="flex items-center gap-1 sm:gap-2 bg-red-50 text-red-600 px-2 sm:px-4 py-1.5 sm:py-2 rounded-lg sm:rounded-2xl font-bold text-xs sm:text-sm hover:bg-red-100 transition-all active:scale-95 whitespace-nowrap"
        title="Log out"
      >
        <LogOut size={16} sm:size={20} />
        <span>Logout</span>
      </button>
    </div>

    <!-- Hero Wallet Card -->
    <section class="relative overflow-hidden rounded-2xl sm:rounded-[3.5rem] bg-gradient-to-br from-blue-500 via-blue-600 to-indigo-600 p-4 sm:p-6 lg:p-10 text-white shadow-2xl shadow-blue-100 uppercase italic mx-2">
      <div class="relative z-10 flex flex-col sm:flex-row justify-between items-center gap-4 sm:gap-6">
        <div>
          <p class="text-blue-100 text-xs sm:text-sm lg:text-lg font-black tracking-widest">My Treasure</p>
          <h1 class="text-4xl sm:text-5xl lg:text-6xl font-black mt-2">🪙 {kid.balance}</h1>
          <div class="mt-3 sm:mt-6 flex items-center gap-2 bg-white/20 backdrop-blur-md px-3 sm:px-4 py-1.5 sm:py-2 rounded-xl sm:rounded-2xl border border-white/30 w-fit text-xs sm:text-sm">
            <Sparkles size={16} sm:size={20} class="text-yellow-400" />
            <span class="font-black">Level: Master Explorer</span>
          </div>
        </div>
        <div class="bg-white/20 p-3 sm:p-4 lg:p-6 rounded-xl sm:rounded-[2rem] backdrop-blur-xl shadow-inner rotate-3">
          <Wallet size={40} sm:size={52} lg:size={64} />
        </div>
      </div>
      <div class="absolute -top-12 -right-12 w-40 sm:w-64 h-40 sm:h-64 bg-white/10 rounded-full blur-3xl"></div>
      <div class="absolute -bottom-12 -left-12 w-40 sm:w-64 h-40 sm:h-64 bg-yellow-400/20 rounded-full blur-3xl"></div>
    </section>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-3 sm:gap-4 lg:gap-8 px-2">
      <!-- Today's Tasks -->
      <div class="bg-white rounded-2xl sm:rounded-[3rem] p-4 sm:p-6 lg:p-8 shadow-xl border-b-4 sm:border-b-[12px] border-blue-400">
        <div class="flex justify-between items-center gap-2 mb-4 sm:mb-6 lg:mb-8">
          <h2 class="text-2xl sm:text-3xl font-black text-gray-900 tracking-tight italic">Missions</h2>
          <a href="/kid/{kidId}/tasks" class="bg-blue-50 text-blue-500 p-2 rounded-lg sm:rounded-2xl hover:bg-blue-100 transition-colors">
            <ArrowRight size={20} sm:size={24} />
          </a>
        </div>
        <div class="space-y-2 sm:space-y-4">
          {#each tasks as task}
            <div class="flex items-center justify-between p-3 sm:p-5 bg-gray-50 rounded-xl sm:rounded-[2rem] border-2 border-transparent transition-all">
              <div class="flex items-center gap-3 sm:gap-4 flex-1 min-w-0">
                <div class="bg-white p-2 sm:p-3 rounded-lg sm:rounded-2xl shadow-sm text-blue-500 flex-shrink-0">
                  <CheckCircle size={20} sm:size={24} class={task.status === 'completed' ? 'fill-blue-500 text-white' : ''} />
                </div>
                <div class="min-w-0 flex-1">
                  <p class="font-black text-gray-800 text-sm sm:text-lg {task.status === 'completed' ? 'line-through opacity-50' : ''} truncate">{task.title}</p>
                  <p class="text-yellow-600 font-black text-xs sm:text-base">🪙 {task.reward}</p>
                </div>
              </div>
            </div>
          {:else}
            <p class="text-center text-gray-400 font-bold py-4 text-sm sm:text-base">No missions yet. Ask your parents! 😊</p>
          {/each}
        </div>
      </div>

      <!-- Habit Adventure Tile -->
      <div class="bg-pink-500 rounded-2xl sm:rounded-[3rem] p-4 sm:p-6 lg:p-8 text-white shadow-xl shadow-pink-100 flex flex-col justify-between border-b-4 sm:border-b-[12px] border-pink-700 relative overflow-hidden group">
        <div class="relative z-10">
          <div class="bg-white/20 w-fit p-2 sm:p-4 rounded-lg sm:rounded-[1.5rem] mb-4 sm:mb-6 shadow-inner group-hover:rotate-12 transition-transform">
            <Gamepad2 size={32} sm:size={40} />
          </div>
          <h2 class="text-2xl sm:text-3xl font-black mb-1 sm:mb-2 tracking-tight">Habit World</h2>
          <p class="font-bold opacity-90 text-sm sm:text-lg">Play games and master good habits! 🎮</p>
        </div>
        <a href="/kid/1/habits" class="relative z-10 mt-4 sm:mt-8 bg-white text-pink-500 font-black py-3 sm:py-5 rounded-lg sm:rounded-[2rem] text-center text-sm sm:text-xl shadow-lg active:scale-95 transition-all">
          Start Adventure
        </a>
        <div class="absolute -right-10 -top-10 opacity-10 rotate-12">
          <Brain size={120} sm:size={200} />
        </div>
      </div>
    </div>

    <!-- Goal Progress -->
    <div class="bg-white rounded-2xl sm:rounded-[4rem] p-4 sm:p-8 lg:p-10 shadow-xl border-2 border-gray-50 flex flex-col lg:flex-row items-center gap-4 sm:gap-6 lg:gap-10 mx-2">
      <div class="relative w-32 h-32 sm:w-40 sm:h-40 lg:w-48 lg:h-48 flex-shrink-0">
        <svg class="w-full h-full" viewBox="0 0 100 100">
          <circle cx="50" cy="50" r="45" fill="none" stroke="#f3f4f6" stroke-width="10" />
          <circle cx="50" cy="50" r="45" fill="none" stroke="#facc15" stroke-width="10" 
                  stroke-dasharray="282.7" stroke-dashoffset={282.7 * (1 - progress / 100)}
                  stroke-linecap="round" class="transition-all duration-1000 ease-out shadow-lg" />
        </svg>
        <div class="absolute inset-0 flex flex-col items-center justify-center">
          <span class="text-2xl sm:text-4xl font-black text-gray-900">{progress}%</span>
        </div>
      </div>
      <div class="flex-1 space-y-3 sm:space-y-4 text-center lg:text-left">
        <h3 class="text-2xl sm:text-3xl font-black text-gray-900">Next Big Prize: {goalName}</h3>
        <p class="text-sm sm:text-lg lg:text-xl text-gray-400 font-bold italic">Keep up the great habits, you're almost there! 🌟</p>
        <div class="bg-yellow-50 text-yellow-700 px-4 sm:px-6 py-2 sm:py-3 rounded-lg sm:rounded-2xl w-fit mx-auto lg:mx-0 font-black text-sm sm:text-base border border-yellow-100">
          Need 🪙 350 more
        </div>
      </div>
    </div>
  {/if}
</div>

