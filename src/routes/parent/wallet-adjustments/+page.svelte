<!-- Page: Parent Wallet Adjustments -->
<script lang="ts">
  import { Coins, Plus, Minus, Send, User, Loader2 } from 'lucide-svelte';
  import { fade } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  let familyId = $state('');
  let kids = $state<any[]>([]);
  let amount = $state(0);
  let selectedKidId = $state('');
  let loading = $state(true);
  let processing = $state(false);

  onMount(async () => {
    familyId = localStorage.getItem('family_id');
    if (!familyId) {
       window.location.href = '/login';
       return;
    }
    await fetchKids();
  });

  async function fetchKids() {
    loading = true;
    const { data } = await supabase.from('kids').select('*').eq('family_id', familyId);
    kids = data || [];
    if (kids.length > 0) selectedKidId = kids[0].id;
    loading = false;
  }

  async function handleConfirm() {
    if (!selectedKidId) return;

    processing = true;
    try {
      const kid = kids.find(k => k.id === selectedKidId);
      const newBalance = (kid?.balance || 0) + amount;

      const { error } = await supabase
        .from('kids')
        .update({ balance: newBalance })
        .eq('id', selectedKidId);
      
      if (error) throw error;

      alert(`Adjusted balance by ${amount} coins!`);
      amount = 0;
      await fetchKids();
    } catch (e) {
      console.error('Adjustment failed:', e);
    } finally {
      processing = false;
    }
  }
</script>

<div class="space-y-6" in:fade>
  <header class="bg-white p-6 rounded-[2.5rem] shadow-sm border-b-4 border-yellow-200">
    <h1 class="text-3xl font-black text-gray-900">Quick Adjustment</h1>
    <p class="text-yellow-600 font-bold italic">Grant or remove coins instantly 🪙</p>
  </header>

  {#if loading}
    <div class="flex justify-center py-20">
      <Loader2 size={48} class="animate-spin text-yellow-500" />
    </div>
  {:else}
    <div class="bg-white p-8 rounded-[3rem] shadow-sm border border-gray-100 space-y-8">
      <div class="space-y-4">
        <label class="text-sm font-black text-gray-400 uppercase tracking-widest ml-4">Select Kid</label>
        <div class="flex gap-4 overflow-x-auto pb-2 no-scrollbar">
          {#each kids as kid}
            <button 
              onclick={() => selectedKidId = kid.id}
              class="flex-1 min-w-[120px] py-4 rounded-[1.5rem] font-black border-2 transition-all {selectedKidId === kid.id ? 'bg-blue-500 text-white border-blue-500 shadow-lg shadow-blue-100' : 'bg-gray-50 text-gray-400 border-transparent'}"
            >
              {kid.name}
            </button>
          {:else}
             <p class="text-gray-400 font-bold italic">No kids found.</p>
          {/each}
        </div>
      </div>

      <div class="text-center space-y-4">
        <span class="text-6xl font-black text-gray-900 leading-none">🪙 {amount}</span>
        <div class="flex justify-center gap-6">
          <button onclick={() => amount += 10} class="w-16 h-16 bg-blue-100 text-blue-600 rounded-2xl flex items-center justify-center hover:scale-110 active:scale-95 transition-all">
            <Plus size={32} />
          </button>
          <button onclick={() => amount = amount - 10} class="w-16 h-16 bg-red-100 text-red-600 rounded-2xl flex items-center justify-center hover:scale-110 active:scale-95 transition-all">
            <Minus size={32} />
          </button>
        </div>
      </div>

      <button 
        onclick={handleConfirm}
        disabled={processing || !selectedKidId}
        class="w-full bg-yellow-500 text-white p-6 rounded-[2rem] text-2xl font-black shadow-xl shadow-yellow-100 hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-3 disabled:opacity-50"
      >
        {#if processing}
          <Loader2 size={28} class="animate-spin" />
        {:else}
          Confirm Adjustment <Send size={28} />
        {/if}
      </button>
    </div>
  {/if}
</div>
