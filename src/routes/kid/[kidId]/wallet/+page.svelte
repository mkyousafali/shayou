<!-- Page: Kid Wallet -->
<script lang="ts">
  import { Wallet, TrendingUp, History, ArrowUpRight, ArrowDownLeft, ChevronLeft, Loader2 } from 'lucide-svelte';
  import { fade, slide } from 'svelte/transition';
  import { page } from '$app/state';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  const { kidId } = page.params;
  let loading = $state(true);
  let balance = $state(0);
  let history = $state<any[]>([]);

  onMount(async () => {
    await fetchData();
  });

  async function fetchData() {
    loading = true;
    try {
      // Fetch kid balance
      const { data: kid, error: kidError } = await supabase
        .from('kids')
        .select('balance')
        .eq('id', kidId)
        .single();
      
      if (kidError) throw kidError;
      balance = kid?.balance || 0;

      // Fetch Task History (Approved tasks)
      const { data: tasks, error: taskError } = await supabase
        .from('tasks')
        .select('*')
        .eq('kid_id', kidId)
        .eq('status', 'approved')
        .order('completed_at', { ascending: false })
        .limit(10);
      
      if (taskError) throw taskError;
      
      // Normalize history
      history = (tasks || []).map(t => ({
        id: t.id,
        title: t.title,
        amount: t.reward,
        date: new Date(t.completed_at || t.updated_at).toLocaleDateString(),
        type: 'earn',
        color: 'blue'
      }));

    } catch (e) {
      console.error('Error fetching wallet data:', e);
    } finally {
      loading = false;
    }
  }
</script>

<div class="space-y-6 pb-24" in:fade>
  <header class="flex items-center gap-4 py-4">
    <a href="/kid/{kidId}/home" class="p-3 bg-white rounded-2xl shadow-sm text-gray-500 hover:text-blue-500">
      <ChevronLeft size={24} />
    </a>
    <div>
      <h1 class="text-2xl font-black text-gray-900">My Treasure Box</h1>
      <p class="text-yellow-500 font-bold text-sm italic">See all your earnings! 🪙</p>
    </div>
  </header>

  {#if loading}
    <div class="bg-blue-500 p-20 rounded-[4rem] text-white flex flex-col items-center justify-center gap-4">
      <Loader2 size={48} class="animate-spin" />
      <p class="font-black italic">Counting your treasure...</p>
    </div>
  {:else}
    <!-- Big Balance Card -->
    <div class="bg-gradient-to-br from-blue-500 to-blue-700 p-10 rounded-[4rem] text-white shadow-2xl shadow-blue-200 relative overflow-hidden">
      <div class="relative z-10 space-y-2">
        <span class="text-blue-200 font-black uppercase tracking-[0.2em] text-sm">Main Savings</span>
        <div class="flex items-baseline gap-2">
          <span class="text-6xl font-black">🪙 {balance}</span>
        </div>
        <div class="flex gap-4 pt-4">
          <div class="bg-white/20 px-4 py-2 rounded-2xl flex items-center gap-2">
            <TrendingUp size={16} />
            <span class="font-bold">+100% this week</span>
          </div>
        </div>
      </div>
      <div class="absolute -right-10 -bottom-10 opacity-20">
        <Wallet size={200} />
      </div>
    </div>

    <div class="flex justify-between items-center px-4 pt-4">
      <h2 class="text-xl font-black text-gray-800 flex items-center gap-2">
        <History size={20} class="text-pink-500" /> Recent History
      </h2>
    </div>

    {#if history.length === 0}
      <div class="bg-gray-50 p-12 rounded-[2.5rem] border-2 border-dashed border-gray-200 text-center text-gray-400">
        <p class="font-bold">No history yet. Start finishing quests to earn coins!</p>
      </div>
    {:else}
      <div class="space-y-3">
        {#each history as item, i}
          <div 
            in:slide={{ delay: i * 100 }}
            class="bg-white p-5 rounded-[2.5rem] shadow-sm flex items-center justify-between border-2 border-transparent border-blue-50 transition-all"
          >
            <div class="flex items-center gap-4">
              <div class="p-3 rounded-2xl bg-blue-50 text-blue-500">
                {#if item.amount > 0}
                  <ArrowUpRight size={20} />
                {:else}
                  <ArrowDownLeft size={20} />
                {/if}
              </div>
              <div>
                <h4 class="font-black text-gray-800">{item.title}</h4>
                <p class="text-xs text-gray-400 font-bold">{item.date}</p>
              </div>
            </div>
            <div class="text-right">
              <p class="text-lg font-black {item.amount > 0 ? 'text-green-500' : 'text-red-500'}">
                {item.amount > 0 ? '+' : ''}{item.amount} 🪙
              </p>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  {/if}
</div>
