<!-- Page: Parent Kids -->
<script lang="ts">
  import { UserPlus, Settings, Heart, Baby, ChevronRight, Loader2 } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  let familyId = $state('');
  let kids = $state<any[]>([]);
  let loading = $state(true);
  let showAddForm = $state(false);
  let newKid = $state({ name: '', code: '', confirmCode: '' });
  let errorMessage = $state('');

  onMount(async () => {
    const stored = localStorage.getItem('family_id');
    if (!stored) {
      window.location.href = '/login';
      return;
    }
    familyId = stored;
    await fetchKids();
  });

  async function fetchKids() {
    loading = true;
    const { data, error } = await supabase
      .from('kids')
      .select('*')
      .eq('family_id', familyId);
    
    if (!error) kids = data || [];
    loading = false;
  }

  async function handleAddKid() {
    if (!newKid.name || newKid.code.length !== 6 || newKid.code !== newKid.confirmCode) {
      errorMessage = "Please fill all fields and unique codes!";
      return;
    }

    loading = true;
    errorMessage = '';

    try {
      const { error } = await supabase
        .from('kids')
        .insert([{ 
          family_id: familyId, 
          name: newKid.name, 
          access_code: newKid.code,
          avatar_url: '👤'
        }]);

      if (error) throw error;

      showAddForm = false;
      newKid = { name: '', code: '', confirmCode: '' };
      await fetchKids();
    } catch (e) {
      errorMessage = e.message;
    } finally {
      loading = false;
    }
  }
</script>

<div class="space-y-6 pb-24" in:fade>
  <header class="flex justify-between items-center bg-white p-6 rounded-[2.5rem] shadow-sm border-b-4 border-yellow-200">
    <div>
      <h1 class="text-3xl font-black text-gray-900">My Little Ones</h1>
      <p class="text-yellow-600 font-bold italic">Manage your family profiles ✨</p>
    </div>
    <button 
      onclick={() => { showAddForm = true; errorMessage = ''; }}
      class="bg-blue-500 text-white p-4 rounded-3xl shadow-lg hover:scale-105 transition-transform active:scale-95"
    >
      <UserPlus size={32} />
    </button>
  </header>

  {#if showAddForm}
    <div class="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-6" transition:fade>
      <div class="bg-white w-full max-w-lg rounded-[3rem] p-10 shadow-3xl border-b-[16px] border-blue-400 relative" in:fly={{ y: 50 }}>
        <h2 class="text-4xl font-black text-gray-900 mb-2 italic">New Kid Profile 🎈</h2>
        <p class="text-gray-500 font-bold mb-8">Creating a new account for your child!</p>
        
        {#if errorMessage}
          <p class="text-red-500 font-bold text-center mb-4">{errorMessage}</p>
        {/if}

        <div class="space-y-6">
          <div class="space-y-2">
            <label class="text-sm font-black text-gray-400 uppercase tracking-widest ml-4">Child's Name</label>
            <input type="text" bind:value={newKid.name} placeholder="Name" class="w-full px-8 py-5 rounded-[2rem] bg-gray-50 border-2 border-transparent focus:border-blue-400 outline-none font-bold text-xl" />
          </div>
          
          <div class="grid grid-cols-2 gap-4">
             <div class="space-y-2">
              <label class="text-sm font-black text-gray-400 uppercase tracking-widest ml-4">Access Code</label>
              <input type="password" maxlength="6" bind:value={newKid.code} placeholder="******" class="w-full px-8 py-5 rounded-[2rem] bg-gray-50 border-2 border-transparent focus:border-blue-400 outline-none font-bold text-xl text-center" />
            </div>
             <div class="space-y-2">
              <label class="text-sm font-black text-gray-400 uppercase tracking-widest ml-4">Re-type Code</label>
              <input type="password" maxlength="6" bind:value={newKid.confirmCode} placeholder="******" class="w-full px-8 py-5 rounded-[2rem] bg-gray-50 border-2 border-transparent focus:border-blue-400 outline-none font-bold text-xl text-center" />
            </div>
          </div>

          <div class="flex gap-4 pt-4">
            <button 
              onclick={() => showAddForm = false}
              class="flex-1 py-5 rounded-[2rem] font-black text-gray-400 hover:bg-gray-100 transition-all"
            >
              Cancel
            </button>
            <button 
              onclick={handleAddKid}
              disabled={loading}
              class="flex-[2] bg-blue-500 text-white py-5 rounded-[2rem] font-black text-xl shadow-xl shadow-blue-200 hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-2"
            >
              {#if loading}
                <Loader2 class="animate-spin" />
              {:else}
                Create Profil! 🚀
              {/if}
            </button>
          </div>
        </div>
      </div>
    </div>
  {/if}

  {#if loading && !showAddForm}
    <div class="flex flex-col items-center py-20 gap-4 text-blue-400">
      <Loader2 size={48} class="animate-spin" />
      <p class="font-black italic">Loading profiles...</p>
    </div>
  {:else}
    <div class="space-y-4">
      {#each kids as kid, i}
        <div 
          in:fly={{ y: 20, delay: i * 100 }}
          class="bg-white p-6 rounded-[2.5rem] shadow-sm border border-gray-100 flex items-center justify-between group hover:shadow-md transition-all"
        >
          <div class="flex items-center gap-4">
            <div class="w-16 h-16 rounded-[1.5rem] bg-blue-100 flex items-center justify-center text-4xl shadow-inner group-hover:rotate-6 transition-transform">
              {kid.avatar_url || '👤'}
            </div>
            <div>
              <h3 class="font-black text-gray-800 text-xl">{kid.name}</h3>
              <p class="text-sm font-bold text-gray-400 italic">🪙 {kid.balance}</p>
            </div>
          </div>
          <div class="flex gap-2">
            <button class="p-3 bg-gray-50 text-gray-400 rounded-2xl hover:bg-blue-50 hover:text-blue-500 transition-colors">
              <Settings size={20} />
            </button>
            <a href="/parent/dashboard" class="p-3 bg-blue-500 text-white rounded-2xl shadow-lg shadow-blue-100">
              <ChevronRight size={20} />
            </a>
          </div>
        </div>
      {:else}
        <button class="bg-gray-50 border-4 border-dashed border-gray-200 rounded-[2.5rem] p-10 flex flex-col items-center justify-center text-gray-400 hover:bg-white hover:border-pink-300 hover:text-pink-400 transition-all duration-300 group cursor-pointer w-full" onclick={() => showAddForm = true}>
          <div class="w-20 h-20 rounded-[1.5rem] bg-gray-100 flex items-center justify-center mb-4 group-hover:scale-110 group-hover:rotate-12 transition-all">
            <Baby size={40} />
          </div>
          <p class="text-xl font-black">Add Your First Child</p>
        </button>
      {/each}
    </div>
  {/if}
</div>
