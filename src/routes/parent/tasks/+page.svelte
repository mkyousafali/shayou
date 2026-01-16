<!-- Page: Parent Tasks -->
<script lang="ts">
  import { Plus, ListTodo, CheckCircle2, Clock, Calendar, Loader2, X } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  let activeTab = $state('active'); // 'active', 'completed', 'scheduled'
  let familyId = $state('');
  let kids = $state<any[]>([]);
  let tasks = $state<any[]>([]);
  let loading = $state(true);
  let showAddForm = $state(false);
  
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
          .select('*, kids(name)')
          .in('kid_id', kids.map(k => k.id))
          .order('created_at', { ascending: false });
        
        if (error) throw error;
        tasks = tasksData || [];
      }
    } catch (e) {
      console.error('Error fetching tasks:', e);
    } finally {
      loading = false;
    }
  }

  async function handleAddTask() {
    if (!newTask.title || !newTask.kid_id) {
      alert("Please enter a title and select a kid!");
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
    }
  }

  // Filter tasks based on tab
  let filteredTasks = $derived(
    tasks.filter(t => {
      if (activeTab === 'active') return t.status === 'available' || t.status === 'pending';
      if (activeTab === 'completed') return t.status === 'approved';
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
          <div class="flex items-center gap-4">
            <div class="bg-blue-100 p-3 rounded-2xl text-blue-600">
              <ListTodo size={24} />
            </div>
            <div>
              <h3 class="font-black text-gray-800 text-xl">{task.title}</h3>
              <div class="flex items-center gap-2">
                <span class="text-xs font-black text-blue-500 uppercase tracking-widest bg-blue-50 px-2 py-0.5 rounded-md">{task.kids?.name}</span>
                <span class="text-xs font-bold text-gray-400 uppercase tracking-widest">{task.category}</span>
                {#if task.status === 'pending'}
                  <span class="text-[10px] font-black text-yellow-600 bg-yellow-50 px-2 py-0.5 rounded-full animate-pulse">PENDING APPROVAL</span>
                {/if}
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-4 py-2 rounded-2xl border-2 border-gray-100">
            <span class="font-black text-2xl text-yellow-500">🪙 {task.reward}</span>
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
</div>
