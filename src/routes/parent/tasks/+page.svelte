<!-- Page: Parent Tasks -->
<script lang="ts">
  import { Plus, ListTodo, CheckCircle2, Clock, Calendar, Loader2, X, Check, XCircle, AlertCircle } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';
  import Modal from '$lib/components/Modal.svelte';

  let activeTab = $state('active'); // 'active', 'completed', 'scheduled'
  let familyId = $state('');
  let kids = $state<any[]>([]);
  let tasks = $state<any[]>([]);
  let loading = $state(true);
  let showAddForm = $state(false);
  let approvingId = $state('');
  let showRejectModal = $state(false);
  let rejectTaskId = $state('');
  let rejectMessage = $state('');
  let showErrorModal = $state(false);
  let errorMessage = $state('');
  let errorTitle = $state('Error');
  
  // New Task State
  let newTask = $state({
    title: '',
    reward: 50,
    category: 'Life Skill',
    kid_id: ''
  });

  onMount(async () => {
    familyId = localStorage.getItem('family_id');
    if (!familyId) {
       window.location.href = '/login';
       return;
    }
    await fetchData();
  });

  async function fetchData() {
    loading = true;
    try {
      // Fetch Kids
      const { data: kidsData } = await supabase.from('kids').select('*').eq('family_id', familyId);
      kids = kidsData || [];

      if (kids.length > 0) {
        // Fetch All Tasks
        const { data: tasksData, error } = await supabase
          .from('tasks')
          .select('*')
          .in('kid_id', kids.map(k => k.id))
          .order('created_at', { ascending: false });
        
        if (error) throw error;
        // Map kid names
        tasks = (tasksData || []).map(task => ({
          ...task,
          kids: { name: kids.find(k => k.id === task.kid_id)?.name }
        }));
      }
    } catch (e) {
      console.error('Error fetching tasks:', e);
    } finally {
      loading = false;
    }
  }

  async function handleAddTask() {
    if (!newTask.title || !newTask.kid_id) {
      errorTitle = 'Missing Information';
      errorMessage = 'Please enter a task title and select a kid!';
      showErrorModal = true;
      return;
    }

    try {
      const { error } = await supabase
        .from('tasks')
        .insert([{
          kid_id: newTask.kid_id,
          title: newTask.title,
          reward: newTask.reward,
          category: newTask.category,
          status: 'available'
        }]);

      if (error) throw error;

      showAddForm = false;
      newTask = { title: '', reward: 50, category: 'Life Skill', kid_id: '' };
      await fetchData();
    } catch (e) {
      console.error('Error adding task:', e);
      errorTitle = 'Error Adding Task';
      errorMessage = e instanceof Error ? e.message : String(e);
      showErrorModal = true;
    }
  }

  async function handleApproveTask(taskId: string) {
    approvingId = taskId;
    try {
      // Find the task to get kid_id and reward
      const task = tasks.find(t => t.id === taskId);
      if (!task) throw new Error('Task not found');

      // Update task status to completed
      const { error: taskError } = await supabase
        .from('tasks')
        .update({ status: 'completed', completed_at: new Date().toISOString() })
        .eq('id', taskId);

      if (taskError) throw taskError;

      // Get the kid's current balance
      const { data: kidData, error: kidError } = await supabase
        .from('kids')
        .select('balance')
        .eq('id', task.kid_id)
        .single();

      if (kidError) throw kidError;

      // Add reward to kid's balance
      const newBalance = (kidData.balance || 0) + task.reward;
      const { error: balanceError } = await supabase
        .from('kids')
        .update({ balance: newBalance })
        .eq('id', task.kid_id);

      if (balanceError) throw balanceError;

      await fetchData();
    } catch (e) {
      errorTitle = 'Error Approving Task';
      errorMessage = e instanceof Error ? e.message : String(e);
      showErrorModal = true;
      console.error(e);
    } finally {
      approvingId = '';
    }
  }

  async function handleRejectTask(taskId: string) {
    rejectTaskId = taskId;
    showRejectModal = true;
    rejectMessage = '';
  }

  async function confirmRejectRetry() {
    try {
      const task = tasks.find(t => t.id === rejectTaskId);
      if (!task) throw new Error('Task not found');

      // Reset task to available so kid can try again
      const { error: taskError } = await supabase
        .from('tasks')
        .update({ status: 'available' })
        .eq('id', rejectTaskId);

      if (taskError) throw taskError;

      // Get the kid's current balance
      const { data: kidData, error: kidError } = await supabase
        .from('kids')
        .select('balance')
        .eq('id', task.kid_id)
        .single();

      if (kidError) throw kidError;

      // Deduct reward from kid's balance
      const newBalance = (kidData.balance || 0) - task.reward;
      const { error: balanceError } = await supabase
        .from('kids')
        .update({ balance: newBalance })
        .eq('id', task.kid_id);

      if (balanceError) throw balanceError;
      
      rejectMessage = '✅ Task reset! Kid can try again. Coins deducted as penalty.';
      setTimeout(() => {
        showRejectModal = false;
        rejectTaskId = '';
        rejectMessage = '';
        fetchData();
      }, 1500);
    } catch (e) {
      rejectMessage = '❌ Error: ' + (e instanceof Error ? e.message : String(e));
    }
  }

  async function confirmRejectDelete() {
    try {
      // Delete the task completely
      const { error: deleteError } = await supabase
        .from('tasks')
        .delete()
        .eq('id', rejectTaskId);

      if (deleteError) throw deleteError;
      
      rejectMessage = '🗑️ Task deleted completely.';
      setTimeout(() => {
        showRejectModal = false;
        rejectTaskId = '';
        rejectMessage = '';
        fetchData();
      }, 1500);
    } catch (e) {
      rejectMessage = '❌ Error: ' + (e instanceof Error ? e.message : String(e));
    }
  }

  // Filter tasks based on tab
  let filteredTasks = $derived(
    tasks.filter(t => {
      if (activeTab === 'active') return t.status === 'available' || t.status === 'pending';
      if (activeTab === 'completed') return t.status === 'completed';
      return false;
    })
  );
</script>

<div class="space-y-6" in:fade>
  <header class="flex justify-between items-center bg-white p-6 rounded-[2.5rem] shadow-sm border-b-4 border-blue-200">
    <div>
      <h1 class="text-3xl font-black text-gray-900">Task Board</h1>
      <p class="text-blue-500 font-bold italic">Assign chores for your little ones ✨</p>
    </div>
    <button 
      onclick={() => showAddForm = true}
      class="bg-blue-500 text-white p-4 rounded-3xl shadow-lg shadow-blue-100 hover:scale-105 transition-transform active:scale-95"
    >
      <Plus size={32} />
    </button>
  </header>

  <div class="flex gap-4 px-2 overflow-x-auto pb-2 no-scrollbar">
    <button 
      onclick={() => activeTab = 'active'}
      class="flex items-center gap-2 px-6 py-4 rounded-2xl font-black whitespace-nowrap transition-all {activeTab === 'active' ? 'bg-blue-500 text-white shadow-lg' : 'bg-white text-gray-500 shadow-sm border-2 border-transparent'}"
    >
      <Clock size={20} /> Active
    </button>
    <button 
      onclick={() => activeTab = 'completed'}
      class="flex items-center gap-2 px-6 py-4 rounded-2xl font-black whitespace-nowrap transition-all {activeTab === 'completed' ? 'bg-pink-500 text-white shadow-lg' : 'bg-white text-gray-500 shadow-sm border-2 border-transparent'}"
    >
      <CheckCircle2 size={20} /> History
    </button>
  </div>

  {#if loading}
    <div class="flex flex-col items-center justify-center py-20 gap-4 text-blue-500">
      <Loader2 size={48} class="animate-spin" />
      <p class="font-black italic text-xl">Loading missions...</p>
    </div>
  {:else if filteredTasks.length === 0}
    <div class="text-center py-20 bg-gray-50 rounded-[3rem] border-2 border-dashed border-gray-200">
      <p class="text-gray-400 font-bold text-xl">No tasks here yet! 🚀</p>
    </div>
  {:else}
    <div class="space-y-4">
      {#each filteredTasks as task, i}
        <div 
          in:fly={{ y: 20, delay: i * 50 }}
          class="bg-white p-6 rounded-[2rem] border-l-[12px] shadow-sm flex items-center justify-between border-blue-400 hover:shadow-md transition-shadow"
        >
          <div class="flex items-center gap-3">
            <div class="bg-blue-100 p-3 rounded-2xl text-blue-600">
              <ListTodo size={24} />
            </div>
            <div>
              <h3 class="font-black text-gray-800 text-xl">{task.title}</h3>
              <div class="flex items-center gap-2 flex-wrap">
                <span class="text-xs font-black text-blue-500 uppercase tracking-widest bg-blue-50 px-2 py-0.5 rounded-md">{task.kids?.name}</span>
                <span class="text-xs font-bold text-gray-400 uppercase tracking-widest">{task.category}</span>
                {#if task.status === 'pending'}
                  <span class="text-[10px] font-black text-yellow-600 bg-yellow-50 px-2 py-0.5 rounded-full animate-pulse">PENDING APPROVAL</span>
                {/if}
              </div>
            </div>
          </div>
          <div class="flex items-center gap-3">
            {#if task.status === 'pending'}
              <button
                onclick={() => handleApproveTask(task.id)}
                disabled={approvingId === task.id}
                class="bg-green-500 text-white px-4 py-2 rounded-xl font-black hover:bg-green-600 transition-colors disabled:opacity-50 flex items-center gap-2"
              >
                <Check size={18} /> Approve
              </button>
              <button
                onclick={() => handleRejectTask(task.id)}
                class="bg-red-500 text-white px-4 py-2 rounded-xl font-black hover:bg-red-600 transition-colors flex items-center gap-2"
              >
                <XCircle size={18} /> Reject
              </button>
            {:else}
              <div class="bg-gray-50 px-4 py-2 rounded-2xl border-2 border-gray-100">
                <span class="font-black text-2xl text-yellow-500">🪙 {task.reward}</span>
              </div>
            {/if}
          </div>
        </div>
      {/each}
    </div>
  {/if}

  {#if showAddForm}
    <div class="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-6" transition:fade>
      <div class="bg-white w-full max-w-lg rounded-[3rem] p-10 shadow-3xl border-b-[16px] border-blue-400 relative" in:fly={{ y: 50 }}>
        <button onclick={() => showAddForm = false} class="absolute top-6 right-6 text-gray-400 hover:text-red-500">
          <X size={24} />
        </button>
        <h2 class="text-4xl font-black text-gray-900 mb-2 italic">New Quest 🚀</h2>
        <p class="text-gray-500 font-bold mb-8">Create a challenge for your child!</p>
        
        <div class="space-y-6">
          <div class="space-y-2">
            <label class="text-sm font-black text-gray-400 uppercase tracking-widest ml-4">What's the mission?</label>
            <input type="text" bind:value={newTask.title} placeholder="e.g., Clean the Playroom" class="w-full px-8 py-5 rounded-[2rem] bg-gray-50 border-2 border-transparent focus:border-blue-400 outline-none font-bold text-xl" />
          </div>

          <div class="space-y-2">
            <label class="text-sm font-black text-gray-400 uppercase tracking-widest ml-4">Assign to Kid</label>
            <select bind:value={newTask.kid_id} class="w-full px-8 py-5 rounded-[2rem] bg-gray-50 border-2 border-transparent focus:border-blue-400 outline-none font-black text-xl appearance-none">
              <option value="" disabled selected>Select Kid</option>
              {#each kids as kid}
                <option value={kid.id}>{kid.name}</option>
              {/each}
            </select>
          </div>
          
          <div class="space-y-2">
            <label class="text-sm font-black text-gray-400 uppercase tracking-widest ml-4">Coin Reward: {newTask.reward}</label>
            <input type="range" min="10" max="500" step="10" bind:value={newTask.reward} class="w-full accent-blue-500" />
          </div>

          <button onclick={handleAddTask} class="w-full bg-blue-500 text-white py-6 rounded-[2rem] font-black text-xl shadow-xl shadow-blue-100 hover:scale-[1.02] active:scale-95 transition-all">
            CREATE QUEST ✨
          </button>
        </div>
      </div>
    </div>
  {/if}

  {#if showRejectModal}
    <div class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-6" transition:fade>
      <div class="bg-white w-full max-w-md rounded-[3rem] p-10 shadow-3xl border-b-[16px] border-red-400" in:fly={{ y: 50 }}>
        <div class="flex items-center gap-3 mb-4">
          <div class="bg-red-100 p-3 rounded-2xl text-red-600">
            <AlertCircle size={28} />
          </div>
          <h2 class="text-2xl font-black text-gray-900">Reject Task</h2>
        </div>
        
        <p class="text-gray-600 font-bold mb-8">What should we do with this task?</p>

        {#if rejectMessage}
          <div class="mb-6 p-4 rounded-2xl bg-gray-50 border-2 border-gray-200 text-center">
            <p class="font-black text-sm">{rejectMessage}</p>
          </div>
        {/if}

        <div class="flex gap-3 flex-col-reverse">
          <button
            onclick={confirmRejectDelete}
            disabled={rejectMessage !== ''}
            class="w-full bg-red-500 text-white py-4 rounded-2xl font-black text-lg shadow-lg shadow-red-100 hover:bg-red-600 transition-colors active:scale-95 disabled:opacity-50"
          >
            🗑️ Delete Task
          </button>
          <button
            onclick={confirmRejectRetry}
            disabled={rejectMessage !== ''}
            class="w-full bg-blue-500 text-white py-4 rounded-2xl font-black text-lg shadow-lg shadow-blue-100 hover:bg-blue-600 transition-colors active:scale-95 disabled:opacity-50"
          >
            🔄 Allow Retry
          </button>
        </div>
      </div>
    </div>
  {/if}

  <Modal
    visible={showErrorModal}
    title={errorTitle}
    message={errorMessage}
    icon="error"
    onClose={() => showErrorModal = false}
  />
</div>
