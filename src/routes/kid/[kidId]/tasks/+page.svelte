<!-- Page: Kid Tasks -->
<script lang="ts">
  import { Star, CheckCircle, Zap, ShieldCheck, Loader2 } from 'lucide-svelte';
  import { fade, fly, scale } from 'svelte/transition';
  import { page } from '$app/state';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';
  import Modal from '$lib/components/Modal.svelte';

  const { kidId } = page.params;
  let loading = $state(true);
  let tasks = $state<any[]>([]);
  let showSuccessModal = $state(false);
  let showErrorModal = $state(false);
  let errorMessage = $state('');

  onMount(async () => {
    await fetchTasks();
  });

  async function fetchTasks() {
    loading = true;
    try {
      const { data, error } = await supabase
        .from('tasks')
        .select('*')
        .eq('kid_id', kidId)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      tasks = data || [];
    } catch (e) {
      console.error('Error fetching tasks:', e);
    } finally {
      loading = false;
    }
  }

  async function completeTask(taskId: string) {
    try {
      console.log('Submitting task:', taskId);
      const { data, error } = await supabase
        .from('tasks')
        .update({ status: 'pending' })
        .eq('id', taskId)
        .select();

      console.log('Update response:', { data, error });
      
      if (error) {
        console.error('Supabase error details:', error);
        throw new Error(`${error.message} (${error.code})`);
      }
      
      // Update local state
      tasks = tasks.map(t => t.id === taskId ? { ...t, status: 'pending' } : t);
      
      showSuccessModal = true;
    } catch (e) {
      console.error('Full error:', e);
      errorMessage = e instanceof Error ? e.message : 'Could not submit task. Please try again!';
      showErrorModal = true;
    }
  }

  // Map category to color/icon
  const getTaskMeta = (category: string) => {
    switch (category?.toLowerCase()) {
      case 'learning': return { color: 'pink', icon: Zap };
      case 'health': return { color: 'yellow', icon: ShieldCheck };
      default: return { color: 'blue', icon: Star };
    }
  };
</script>

<div class="space-y-6 pb-24" in:fade>
  <header class="text-center py-6">
    <h1 class="text-5xl font-black text-gray-900 drop-shadow-sm tracking-tighter italic">My Quests 🚀</h1>
    <p class="text-blue-500 font-bold uppercase tracking-widest text-sm mt-2">Level up your life skills!</p>
  </header>

  {#if loading}
    <div class="flex flex-col items-center justify-center py-20 gap-4 text-blue-500">
      <Loader2 size={48} class="animate-spin" />
      <p class="font-black italic text-xl">Loading your quests...</p>
    </div>
  {:else if tasks.length === 0}
    <div class="bg-white p-12 rounded-[3rem] text-center space-y-4 shadow-sm border border-gray-100">
      <div class="text-6xl">😴</div>
      <h2 class="text-2xl font-black text-gray-800">No quests right now!</h2>
      <p class="text-gray-500 font-bold">Ask Mom or Dad to add some new challenges for you!</p>
    </div>
  {:else}
    <div class="space-y-6">
      {#each tasks as task, i}
        {@const meta = getTaskMeta(task.category)}
        <div 
          in:fly={{ x: -20, delay: i * 100 }}
          class="bg-white p-7 rounded-[3.5rem] shadow-xl border-b-[12px] transition-all {task.status !== 'available' ? 'border-gray-200 opacity-60' : 
            meta.color === 'blue' ? 'border-blue-400 active:scale-95' : 
            meta.color === 'pink' ? 'border-pink-400 active:scale-95' : 
            'border-yellow-400 active:scale-95'}"
        >
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-6">
              <div class="p-5 rounded-[2rem] {meta.color === 'blue' ? 'bg-blue-50 text-blue-500' : meta.color === 'pink' ? 'bg-pink-50 text-pink-500' : 'bg-yellow-50 text-yellow-500'} shadow-inner">
                <meta.icon size={36} />
              </div>
              <div>
                <p class="text-xs font-black uppercase tracking-widest text-gray-400 mb-1">{task.category || 'Quest'}</p>
                <h3 class="text-2xl font-black text-gray-800">{task.title}</h3>
                <div class="flex items-center gap-1 mt-1">
                  <span class="text-2xl font-black text-yellow-600">🪙 {task.reward}</span>
                </div>
              </div>
            </div>
            
            {#if task.status === 'available'}
              <button 
                onclick={() => completeTask(task.id)}
                class="bg-blue-500 text-white p-5 rounded-[2rem] shadow-lg shadow-blue-100 hover:rotate-6 transition-all active:scale-90"
              >
                <CheckCircle size={32} />
              </button>
            {:else if task.status === 'pending'}
               <div class="bg-yellow-100 text-yellow-600 p-5 rounded-[2rem] animate-pulse">
                <Loader2 size={32} class="animate-spin" />
              </div>
            {:else}
              <div class="bg-gray-100 text-gray-400 p-5 rounded-[2rem]">
                <CheckCircle size={32} />
              </div>
            {/if}
          </div>
        </div>
      {/each}
    </div>
  {/if}

  <div class="bg-gradient-to-br from-yellow-400 to-orange-500 p-8 rounded-[3rem] text-white shadow-xl relative overflow-hidden">
    <div class="relative z-10">
      <h2 class="text-2xl font-black mb-2">Daily Bonus! 🎁</h2>
      <p class="font-bold opacity-90">Finish quests to level up!</p>
      <div class="mt-4 h-4 bg-white/20 rounded-full overflow-hidden border-2 border-white/30">
        <div class="h-full bg-white w-1/3 shadow-[0_0_20px_rgba(255,255,255,0.5)]"></div>
      </div>
    </div>
    <div class="absolute -right-4 -bottom-4 opacity-20 rotate-12">
      <Star size={120} strokeWidth={3} />
    </div>
  </div>

  <Modal
    visible={showSuccessModal}
    title="Task Submitted!"
    message="Great job! Mom or Dad will check it soon! ✨"
    icon="success"
    onClose={() => showSuccessModal = false}
  />

  <Modal
    visible={showErrorModal}
    title="Oops!"
    message={errorMessage}
    icon="error"
    onClose={() => showErrorModal = false}
  />
</div>
