<!-- Page: Parent Approvals -->
<script lang="ts">
  import { Check, X, Timer, Wallet, Gift, Star, Loader2 } from 'lucide-svelte';
  import { fade, slide } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  let loading = $state(true);
  let familyId = $state('');
  let approvals = $state<any[]>([]);

  onMount(async () => {
    familyId = localStorage.getItem('family_id');
    if (!familyId) {
       window.location.href = '/login';
       return;
    }
    await fetchApprovals();
  });

  async function fetchApprovals() {
    loading = true;
    try {
      // Fetch kids first
      const { data: kidsData } = await supabase.from('kids').select('id, name').eq('family_id', familyId);
      const kidIds = kidsData?.map(k => k.id) || [];

      if (kidIds.length > 0) {
        const { data, error } = await supabase
          .from('tasks')
          .select('*, kids(name)')
          .in('kid_id', kidIds)
          .eq('status', 'pending')
          .order('created_at', { ascending: false });
        
        if (error) throw error;
        approvals = data || [];
      }
    } catch (e) {
      console.error('Error fetching approvals:', e);
    } finally {
      loading = false;
    }
  }

  async function handleApprove(task: any) {
    try {
      // 1. Update task status
      const { error: taskError } = await supabase
        .from('tasks')
        .update({ status: 'approved', completed_at: new Date().toISOString() })
        .eq('id', task.id);
      
      if (taskError) throw taskError;

      // 2. Fetch current balance
      const { data: kidData } = await supabase
        .from('kids')
        .select('balance')
        .eq('id', task.kid_id)
        .single();
      
      const newBalance = (kidData?.balance || 0) + task.reward;

      // 3. Update kid balance
      await supabase
        .from('kids')
        .update({ balance: newBalance })
        .eq('id', task.kid_id);
      
      // Update local state
      approvals = approvals.filter(a => a.id !== task.id);
      alert(`${task.kids.name}'s reward of ${task.reward} coins has been added! ✨`);
    } catch (e) {
      console.error('Approval failed:', e);
      alert("Failed to approve task. Please try again.");
    }
  }

  async function handleDecline(taskId: string) {
     try {
      const { error } = await supabase
        .from('tasks')
        .update({ status: 'available' }) // Send back to available
        .eq('id', taskId);
      
      if (error) throw error;
      approvals = approvals.filter(a => a.id !== taskId);
    } catch (e) {
      console.error('Decline failed:', e);
    }
  }
</script>

<div class="space-y-6" in:fade>
  <header class="bg-white p-6 rounded-[2.5rem] shadow-sm border-b-4 border-red-200">
    <h1 class="text-3xl font-black text-gray-900">Waiting for You</h1>
    <p class="text-red-500 font-bold italic">Review and reward their hard work! ❤️</p>
  </header>

  {#if loading}
    <div class="flex flex-col items-center justify-center py-20 gap-4 text-red-500">
      <Loader2 size={48} class="animate-spin" />
      <p class="font-black italic">Looking for pending rewards...</p>
    </div>
  {:else if approvals.length === 0}
    <div class="text-center py-20 space-y-4">
      <div class="text-6xl italic">🎉</div>
      <h2 class="text-2xl font-black text-gray-800">All caught up!</h2>
      <p class="text-gray-400 font-bold">Nothing to approve right now.</p>
    </div>
  {:else}
    <div class="space-y-4">
      {#each approvals as item (item.id)}
        <div 
          in:slide
          class="bg-white p-6 rounded-[2.5rem] shadow-sm border border-gray-100 flex flex-col gap-4"
        >
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-12 h-12 rounded-2xl bg-blue-500 flex items-center justify-center text-white font-black text-xl shadow-lg">
                {item.kids?.name[0]}
              </div>
              <div>
                <h3 class="font-black text-gray-800">{item.kids?.name} <span class="text-gray-400 font-medium">finished a quest</span></h3>
                <p class="text-xs text-gray-400 flex items-center gap-1 font-bold italic">
                  <Timer size={12} /> {new Date(item.updated_at).toLocaleTimeString()}
                </p>
              </div>
            </div>
            <div class="bg-yellow-50 px-3 py-1 rounded-xl border border-yellow-200">
              <span class="font-black text-yellow-600">🪙 {item.reward}</span>
            </div>
          </div>

          <div class="bg-gray-50 p-4 rounded-2xl flex items-center gap-3 border-2 border-dashed border-gray-200">
            <Star class="text-yellow-500" />
            <span class="font-bold text-gray-700">{item.title}</span>
          </div>

          <div class="flex gap-3">
            <button 
              onclick={() => handleApprove(item)}
              class="flex-1 bg-blue-500 text-white py-4 rounded-2xl font-black flex items-center justify-center gap-2 shadow-lg shadow-blue-100 active:scale-95 transition-all"
            >
              <Check size={20} /> Approve
            </button>
            <button 
              onclick={() => handleDecline(item.id)}
              class="flex-1 bg-gray-100 text-gray-500 py-4 rounded-2xl font-black flex items-center justify-center gap-2 hover:bg-red-50 hover:text-red-500 transition-all active:scale-95"
            >
              <X size={20} /> Decline
            </button>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
