<!-- Page: Parent Spend Requests -->
<script lang="ts">
  import { Wallet, Check, X, Clock, Loader2, Timer } from 'lucide-svelte';
  import { fade, slide } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  let loading = $state(true);
  let familyId = $state('');
  let requests = $state<any[]>([]);

  onMount(async () => {
    familyId = localStorage.getItem('family_id');
    if (!familyId) {
       window.location.href = '/login';
       return;
    }
    await fetchRequests();
  });

  async function fetchRequests() {
    loading = true;
    try {
      const { data: kidsData } = await supabase.from('kids').select('id, name').eq('family_id', familyId);
      const kidIds = kidsData?.map(k => k.id) || [];

      if (kidIds.length > 0) {
        const { data, error } = await supabase
          .from('spend_requests')
          .select('*, kids(name)')
          .in('kid_id', kidIds)
          .eq('status', 'pending')
          .order('created_at', { ascending: false });
        
        if (error) throw error;
        requests = data || [];
      }
    } catch (e) {
      console.error('Error fetching requests:', e);
    } finally {
      loading = false;
    }
  }

  async function handleApprove(req: any) {
    try {
      // 1. Update kid balance (deduct)
      const { data: kidData } = await supabase
        .from('kids')
        .select('balance')
        .eq('id', req.kid_id)
        .single();
      
      if ((kidData?.balance || 0) < req.amount) {
        alert("Kid doesn't have enough coins!");
        return;
      }

      const newBalance = (kidData?.balance || 0) - req.amount;

      // 2. Update balance
      await supabase.from('kids').update({ balance: newBalance }).eq('id', req.kid_id);

      // 3. Update request
      await supabase.from('spend_requests').update({ status: 'approved', updated_at: new Date().toISOString() }).eq('id', req.id);

      requests = requests.filter(r => r.id !== req.id);
      alert("Spend request approved! Coins deducted.");
    } catch (e) {
      console.error('Approval failed:', e);
    }
  }

  async function handleDecline(reqId: string) {
    try {
      await supabase.from('spend_requests').update({ status: 'declined', updated_at: new Date().toISOString() }).eq('id', reqId);
      requests = requests.filter(r => r.id !== reqId);
    } catch (e) {
      console.error('Decline failed:', e);
    }
  }
</script>

<div class="space-y-6" in:fade>
  <header class="bg-white p-6 rounded-[2.5rem] shadow-sm border-b-4 border-pink-200">
    <h1 class="text-3xl font-black text-gray-900">Spend Requests</h1>
    <p class="text-pink-500 font-bold italic">Approve what they want to buy ✨</p>
  </header>

  {#if loading}
    <div class="flex flex-col items-center justify-center py-20 gap-4 text-pink-500">
      <Loader2 size={48} class="animate-spin" />
      <p class="font-black italic">Checking for requests...</p>
    </div>
  {:else if requests.length === 0}
    <div class="text-center py-20 space-y-4">
      <div class="text-6xl italic">🍦</div>
      <h2 class="text-2xl font-black text-gray-800">No requests!</h2>
      <p class="text-gray-400 font-bold">Kids are saving their coins well.</p>
    </div>
  {:else}
    <div class="space-y-4">
      {#each requests as req (req.id)}
        <div in:slide class="bg-white p-6 rounded-[2.5rem] shadow-sm flex items-center justify-between border border-gray-100">
          <div class="flex items-center gap-4">
            <div class="p-4 bg-pink-100 text-pink-500 rounded-2xl">
              <Wallet size={24} />
            </div>
            <div>
              <h3 class="font-black text-gray-800">{req.kids?.name} wants {req.item}</h3>
              <p class="text-xs text-gray-400 font-bold italic flex items-center gap-1">
                <Timer size={12} /> {new Date(req.created_at).toLocaleTimeString()}
              </p>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <div class="text-right mr-4">
              <p class="font-black text-xl text-yellow-500">🪙 {req.amount}</p>
            </div>
            <button onclick={() => handleApprove(req)} class="bg-blue-500 text-white p-3 rounded-xl shadow-lg shadow-blue-100">
              <Check size={20} />
            </button>
            <button onclick={() => handleDecline(req.id)} class="bg-gray-100 text-gray-400 p-3 rounded-xl">
              <X size={20} />
            </button>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
