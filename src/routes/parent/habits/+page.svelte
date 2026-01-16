<!-- Page: Parent Habits -->
<script lang="ts">
  import { Plus, Brain, Trash2, Calendar, Loader2 } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';
  import Modal from '$lib/components/Modal.svelte';

  let familyId = $state('');
  let kids = $state<any[]>([]);
  let habits = $state<any[]>([]);
  let loading = $state(true);
  let showAddForm = $state(false);
  let showErrorModal = $state(false);
  let errorMessage = $state('');
  let errorTitle = $state('Error');
  let showDeleteModal = $state(false);
  let deleteHabitId = $state('');
  
  // New Habit State
  let newHabit = $state({
    title: '',
    description: '',
    frequency: 'daily', // daily, weekly, monthly
    kid_id: '',
    reward: 10
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
        // Fetch Habits - for now, fetch all since there's no habits table yet
        // We'll use goals table as a temporary solution
        const { data: habitsData } = await supabase
          .from('goals')
          .select('*')
          .in('kid_id', kids.map(k => k.id));
        
        habits = habitsData || [];
      }
    } catch (e) {
      console.error('Error fetching habits:', e);
    } finally {
      loading = false;
    }
  }

  async function handleAddHabit() {
    if (!newHabit.title || !newHabit.kid_id) {
      errorTitle = 'Missing Information';
      errorMessage = 'Please enter a habit title and select a kid!';
      showErrorModal = true;
      return;
    }

    try {
      // For now, store habits as goals
      const { error } = await supabase
        .from('goals')
        .insert([{
          kid_id: newHabit.kid_id,
          title: newHabit.title,
          description: newHabit.description,
          category: 'habit',
          status: 'active'
        }]);

      if (error) throw error;

      showAddForm = false;
      newHabit = { title: '', description: '', frequency: 'daily', kid_id: '', reward: 10 };
      await fetchData();
    } catch (e) {
      errorTitle = 'Error Adding Habit';
      errorMessage = e instanceof Error ? e.message : String(e);
      showErrorModal = true;
      console.error('Error adding habit:', e);
    }
  }

  async function handleDeleteHabit(habitId: string) {
    deleteHabitId = habitId;
    showDeleteModal = true;
  }

  async function confirmDeleteHabit() {
    try {
      const { error } = await supabase
        .from('goals')
        .delete()
        .eq('id', deleteHabitId);

      if (error) throw error;
      showDeleteModal = false;
      deleteHabitId = '';
      await fetchData();
    } catch (e) {
      errorTitle = 'Error Deleting Habit';
      errorMessage = 'Could not delete the habit. Please try again.';
      showErrorModal = true;
      showDeleteModal = false;
      console.error(e);
    }
  }
</script>

<div class="space-y-6" in:fade>
  <header class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white p-4 sm:p-6 rounded-2xl sm:rounded-[2.5rem] shadow-sm border-b-4 border-pink-200">
    <div>
      <h1 class="text-2xl sm:text-3xl font-black text-gray-900">Daily Habits</h1>
      <p class="text-pink-500 font-bold italic text-sm sm:text-base">Build amazing routines! 🧠</p>
    </div>
    <button 
      onclick={() => showAddForm = true}
      class="bg-pink-500 text-white p-3 sm:p-4 rounded-2xl sm:rounded-3xl shadow-lg hover:scale-105 active:scale-95 transition-transform"
    >
      <Plus size={28} />
    </button>
  </header>

  {#if showAddForm}
    <div class="bg-white p-4 sm:p-6 lg:p-8 rounded-2xl sm:rounded-[3rem] shadow-xl border-b-4 border-pink-300 space-y-4" transition:fly={{ y: 50 }}>
      <h3 class="text-xl sm:text-2xl font-black text-gray-900">Create New Habit</h3>
      
      <div class="space-y-4">
        <div>
          <label class="block font-bold text-gray-700 text-sm mb-2">Select Kid</label>
          <select bind:value={newHabit.kid_id} class="w-full px-4 py-2 border-2 border-pink-300 rounded-xl focus:outline-none focus:border-pink-600">
            <option value="">Choose a kid...</option>
            {#each kids as kid}
              <option value={kid.id}>{kid.name}</option>
            {/each}
          </select>
        </div>

        <div>
          <label class="block font-bold text-gray-700 text-sm mb-2">Habit Name</label>
          <input 
            type="text" 
            bind:value={newHabit.title}
            placeholder="e.g., Brush teeth, Read a book"
            class="w-full px-4 py-2 border-2 border-pink-300 rounded-xl focus:outline-none focus:border-pink-600"
          />
        </div>

        <div>
          <label class="block font-bold text-gray-700 text-sm mb-2">Description (optional)</label>
          <textarea 
            bind:value={newHabit.description}
            placeholder="Add details about the habit..."
            class="w-full px-4 py-2 border-2 border-pink-300 rounded-xl focus:outline-none focus:border-pink-600 resize-none h-20"
          />
        </div>

        <div>
          <label class="block font-bold text-gray-700 text-sm mb-2">Frequency</label>
          <select bind:value={newHabit.frequency} class="w-full px-4 py-2 border-2 border-pink-300 rounded-xl focus:outline-none focus:border-pink-600">
            <option value="daily">Daily</option>
            <option value="weekly">Weekly</option>
            <option value="monthly">Monthly</option>
          </select>
        </div>

        <div>
          <label class="block font-bold text-gray-700 text-sm mb-2">Reward per completion (coins)</label>
          <input 
            type="number" 
            bind:value={newHabit.reward}
            min="5"
            max="100"
            class="w-full px-4 py-2 border-2 border-pink-300 rounded-xl focus:outline-none focus:border-pink-600"
          />
        </div>
      </div>

      <div class="flex gap-3">
        <button 
          onclick={handleAddHabit}
          class="flex-1 bg-pink-500 text-white font-black py-3 rounded-xl hover:bg-pink-600 transition-colors active:scale-95"
        >
          Create Habit ✨
        </button>
        <button 
          onclick={() => showAddForm = false}
          class="flex-1 bg-gray-200 text-gray-700 font-black py-3 rounded-xl hover:bg-gray-300 transition-colors"
        >
          Cancel
        </button>
      </div>
    </div>
  {/if}

  {#if loading}
    <div class="flex flex-col items-center justify-center py-20 gap-4 text-pink-500">
      <Loader2 size={48} class="animate-spin" />
      <p class="font-black italic">Loading habits...</p>
    </div>
  {:else if habits.length === 0}
    <div class="text-center py-12 bg-pink-50 rounded-2xl border-2 border-dashed border-pink-300">
      <Brain size={48} class="mx-auto text-pink-400 mb-4" />
      <p class="font-black text-gray-700 mb-2">No habits yet</p>
      <p class="text-sm text-gray-600">Create the first daily habit for your kids! 🌟</p>
    </div>
  {:else}
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      {#each habits as habit, i}
        <div 
          in:fly={{ y: 20, delay: i * 100 }}
          class="bg-white p-4 sm:p-5 rounded-2xl sm:rounded-[2rem] shadow-sm border-l-4 border-pink-500 space-y-3 hover:shadow-md transition-shadow"
        >
          <div class="flex justify-between items-start gap-3">
            <div class="flex-1">
              <h3 class="font-black text-gray-900 text-lg">{habit.title}</h3>
              {#if habit.description}
                <p class="text-sm text-gray-600 font-medium mt-1">{habit.description}</p>
              {/if}
            </div>
            <button
              onclick={() => handleDeleteHabit(habit.id)}
              class="text-red-500 hover:text-red-700 hover:bg-red-50 p-2 rounded-lg transition-colors"
            >
              <Trash2 size={18} />
            </button>
          </div>

          <div class="flex items-center gap-2 text-sm font-bold text-pink-600">
            <Calendar size={16} />
            <span>Daily</span>
          </div>

          <div class="bg-pink-50 px-3 py-2 rounded-xl text-center">
            <p class="font-black text-pink-600">🪙 {habit.target || 10} coins</p>
          </div>
        </div>
      {/each}
    </div>
  {/if}

  <Modal
    visible={showErrorModal}
    title={errorTitle}
    message={errorMessage}
    icon="error"
    onClose={() => showErrorModal = false}
  />

  {#if showDeleteModal}
    <div class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4" transition:fade={{ duration: 150 }}>
      <div class="bg-white w-full max-w-md rounded-[2.5rem] p-8 shadow-3xl border-b-4 border-red-400" in:fly={{ y: 30, duration: 250 }}>
        <h2 class="text-2xl font-black text-gray-900 mb-3">Delete Habit</h2>
        <p class="text-gray-600 font-bold mb-8">Are you sure you want to delete this habit? This action cannot be undone.</p>
        
        <div class="flex gap-3 flex-col-reverse">
          <button
            onclick={confirmDeleteHabit}
            class="w-full bg-red-500 text-white py-3 rounded-xl font-black text-lg shadow-lg shadow-red-100 hover:bg-red-600 transition-colors active:scale-95"
          >
            Delete
          </button>
          <button
            onclick={() => showDeleteModal = false}
            class="w-full bg-gray-200 text-gray-900 py-3 rounded-xl font-black text-lg hover:bg-gray-300 transition-colors active:scale-95"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  {/if}
</div>
