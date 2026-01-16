<!-- Page: Kid Goals -->
<script lang="ts">
  import { Trophy, Target, Sparkles, PlusCircle, Gamepad2, Bike, Laptop, Loader2, ChevronLeft } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
  import { page } from '$app/state';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  const { kidId } = page.params;
  let loading = $state(true);
  let goals = $state<any[]>([]);

  onMount(async () => {
    await fetchGoals();
  });

  async function fetchGoals() {
    loading = true;
    try {
      const { data, error } = await supabase
        .from('goals')
        .select('*')
        .eq('kid_id', kidId)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      goals = data || [];
    } catch (e) {
      console.error('Error fetching goals:', e);
    } finally {
      loading = false;
    }
  }

  const getIcon = (iconName: string) => {
    switch (iconName) {
      case 'Gamepad2': return Gamepad2;
      case 'Bike': return Bike;
      case 'Laptop': return Laptop;
      default: return Target;
    }
  };
</script>

<div class="space-y-6 pb-24" in:fade>
  <header class="flex justify-between items-center py-6">
    <div class="flex items-center gap-4">
      <a href="/kid/{kidId}/home" class="p-3 bg-white rounded-2xl shadow-sm text-gray-500 hover:text-blue-500">
        <ChevronLeft size={24} />
      </a>
      <div>
        <h1 class="text-4xl font-black text-gray-900 drop-shadow-sm">My Goals 🎯</h1>
        <p class="text-blue-500 font-bold italic">Save up for bigger prizes!</p>
      </div>
    </div>
    <button class="bg-blue-500 text-white p-4 rounded-3xl shadow-lg hover:scale-105 active:scale-95 transition-all">
      <PlusCircle size={32} />
    </button>
  </header>

  {#if loading}
    <div class="flex flex-col items-center justify-center py-20 gap-4 text-blue-500">
      <Loader2 size={48} class="animate-spin" />
      <p class="font-black italic">Loading your dreams...</p>
    </div>
  {:else if goals.length === 0}
     <div class="bg-white p-12 rounded-[3rem] text-center space-y-4 shadow-sm border border-gray-100">
      <div class="text-6xl">🌟</div>
      <h2 class="text-2xl font-black text-gray-800">No goals set yet!</h2>
      <p class="text-gray-500 font-bold">What are you saving for? Ask Mom or Dad to add a goal!</p>
    </div>
  {:else}
    <div class="space-y-6">
      {#each goals as goal, i}
        {@const Icon = getIcon(goal.icon)}
        <div 
          in:fly={{ y: 20, delay: i * 100 }}
          class="bg-white p-8 rounded-[3rem] shadow-xl border-2 border-gray-50 space-y-4 relative overflow-hidden"
        >
          <div class="flex items-center gap-4 relative z-10">
            <div class="p-5 rounded-[2rem] bg-{goal.color || 'blue'}-100 text-{goal.color || 'blue'}-500 shadow-inner">
              <Icon size={36} />
            </div>
            <div class="flex-1">
              <h3 class="text-2xl font-black text-gray-800">{goal.title}</h3>
              <p class="text-gray-400 font-black">🪙 {goal.current_amount} / {goal.target_amount}</p>
            </div>
            <div class="bg-gray-50 px-4 py-2 rounded-2xl border-2 border-gray-100 font-black text-{goal.color || 'blue'}-500">
              {Math.round((goal.current_amount / goal.target_amount) * 100)}%
            </div>
          </div>

          <div class="w-full h-8 bg-gray-100 rounded-full border-4 border-white shadow-inner overflow-hidden relative">
            <div 
              class="h-full bg-{goal.color || 'blue'}-500 shadow-[0_0_20px_rgba(0,0,0,0.1)] transition-all duration-1000" 
              style="width: {(goal.current_amount / goal.target_amount) * 100}%"
            >
              <div class="w-full h-full bg-white/20 animate-pulse"></div>
            </div>
          </div>

          {#if goal.current_amount / goal.target_amount >= 0.8}
            <div class="bg-yellow-50 text-yellow-600 p-3 rounded-2xl flex items-center justify-center gap-2 font-black text-sm border border-yellow-100">
              <Sparkles size={16} /> YOU'RE ALMOST THERE!
            </div>
          {/if}
        </div>
      {/each}
    </div>
  {/if}

  <div class="flex items-center gap-4 bg-blue-500 p-8 rounded-[3rem] text-white shadow-xl">
    <div class="p-4 bg-white/20 rounded-[1.5rem]">
      <Trophy size={40} />
    </div>
    <div>
      <h3 class="text-xl font-black italic">Pro Saver Tip!</h3>
      <p class="font-bold opacity-80">Check your wallet to see how many coins you have! 🪙</p>
    </div>
  </div>
</div>
