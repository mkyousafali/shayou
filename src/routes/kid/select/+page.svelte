<!-- Page: Kid Select -->
<script lang="ts">
  import { UserPlus, ArrowRight, Star, Loader2 } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  let familyId = '';
  let kids = $state([]);
  let loading = $state(true);
  let selectedKid = $state(null);
  let accessCode = $state("");
  let errorMessage = $state("");

  onMount(async () => {
    // We assume the parent previously logged in or we ask for family code
    familyId = localStorage.getItem('family_id');
    if (!familyId) {
       // If no family_id, we might need to redirect to parent login first
       // or a specific "Find Family" screen. For now, go to login.
       window.location.href = '/login';
       return;
    }
    await fetchKids();
  });

  async function fetchKids() {
    loading = true;
    try {
      if (!familyId) {
        errorMessage = "No family found. Please log in first.";
        loading = false;
        return;
      }

      const { data, error } = await supabase
        .from('kids')
        .select('*')
        .eq('family_id', familyId);
      
      if (error) {
        errorMessage = "Failed to load kids: " + error.message;
        console.error('Supabase error:', error);
      } else {
        kids = data || [];
      }
    } catch (e) {
      errorMessage = "Failed to fetch kids: " + (e instanceof Error ? e.message : String(e));
      console.error('Fetch error:', e);
    } finally {
      loading = false;
    }
  }

  function handleKidSelect(kid) {
    selectedKid = kid;
    accessCode = "";
    errorMessage = "";
  }

  async function handleLogin() {
    if (accessCode.length !== 6) return;
    
    // Validate Kid Code
    if (accessCode === selectedKid.access_code) {
      localStorage.setItem('kid_id', selectedKid.id);
      window.location.href = `/kid/${selectedKid.id}/home`;
    } else {
      errorMessage = "Wrong code! Try again! 🤔";
      accessCode = "";
    }
  }
</script>

<div class="max-w-4xl mx-auto py-12 px-4 space-y-12" in:fade>
  <div class="text-center space-y-4">
    <div class="inline-block p-4 bg-yellow-100 rounded-3xl text-yellow-600 animate-bounce">
      <Star size={40} fill="currentColor" />
    </div>
    <h1 class="text-5xl font-black text-gray-900 tracking-tight">Who are you?</h1>
    <p class="text-xl text-blue-500 font-bold italic">Tap your name to enter your world!</p>
  </div>

  {#if loading}
    <div class="flex flex-col items-center justify-center py-20 gap-4 text-blue-400">
      <Loader2 size={64} class="animate-spin" />
      <p class="text-2xl font-black italic">Finding your profiles...</p>
    </div>
  {:else if errorMessage}
    <div class="bg-red-100 border-2 border-red-400 text-red-700 px-6 py-4 rounded-2xl text-center max-w-md mx-auto mb-8">
      <p class="font-bold text-lg">{errorMessage}</p>
      <button onclick={() => { window.location.href = '/login'; }} class="mt-4 bg-red-500 text-white px-6 py-2 rounded-lg font-bold hover:bg-red-600">
        Back to Login
      </button>
    </div>
  {:else}
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-8">
      {#each kids as kid, i}
        <button 
          onclick={() => handleKidSelect(kid)}
          class="group relative bg-white rounded-[3.5rem] p-10 text-center transition-all duration-500 hover:shadow-[0_40px_80px_-20px_rgba(0,0,0,0.15)] hover:-translate-y-4 border-b-[12px] border-blue-400 active:translate-y-0 active:border-b-4 shadow-xl shadow-blue-50"
          in:fly={{ y: 50, delay: i * 150 }}
        >
          <div class="relative z-10">
            <div class="w-40 h-40 mx-auto rounded-[3rem] bg-blue-100 shadow-inner flex items-center justify-center text-7xl mb-8 group-hover:rotate-6 transition-transform duration-500">
              {kid.avatar_url || '👤'}
            </div>
            <h2 class="text-4xl font-black text-gray-800 mb-4">{kid.name}</h2>
            <div class="inline-flex items-center gap-2 bg-blue-500 text-white px-6 py-3 rounded-2xl font-black shadow-lg">
              Select Me! <ArrowRight size={24} />
            </div>
          </div>
        </button>
      {/each}

      <!-- Add Kid Placeholder -->
      <a href="/parent/kids" class="bg-gray-50 border-4 border-dashed border-gray-200 rounded-[3.5rem] p-10 flex flex-col items-center justify-center text-gray-400 hover:bg-white hover:border-blue-300 hover:text-blue-400 transition-all duration-300 group">
        <div class="w-24 h-24 rounded-[2rem] bg-gray-100 flex items-center justify-center mb-6 group-hover:scale-110 group-hover:rotate-12 transition-all">
          <UserPlus size={48} />
        </div>
        <p class="text-2xl font-black">Add Kid</p>
        <p class="font-bold opacity-60 mt-1">(Requires Parent Code)</p>
      </a>
    </div>
  {/if}

  {#if selectedKid}
    <div class="fixed inset-0 bg-black/60 backdrop-blur-md z-50 flex items-center justify-center p-6" transition:fade>
      <div 
        class="bg-white w-full max-w-md rounded-[4rem] p-12 text-center shadow-2xl border-b-[20px] border-blue-400" 
        in:fly={{ y: 100 }}
      >
        <div class="w-32 h-32 mx-auto rounded-[2.5rem] bg-blue-100 flex items-center justify-center text-6xl mb-8">
          {selectedKid.avatar_url || '👤'}
        </div>
        <h2 class="text-4xl font-black text-gray-900 mb-2 tracking-tighter italic">Hi {selectedKid.name}! 👋</h2>
        <p class="text-gray-500 font-bold mb-10">Enter your 6-digit secret code:</p>
        
        {#if errorMessage}
          <p class="text-red-500 font-black mb-4">{errorMessage}</p>
        {/if}

        <input 
          type="password" 
          maxlength="6"
          bind:value={accessCode}
          placeholder="******" 
          oninput={handleLogin}
          class="w-full text-center text-5xl font-black tracking-[0.3em] py-8 rounded-[2.5rem] bg-gray-50 border-4 border-transparent focus:border-yellow-400 outline-none transition-all placeholder:text-gray-200" 
        />
        
        <div class="mt-10 flex gap-4">
          <button 
            onclick={() => selectedKid = null}
            class="flex-1 py-6 rounded-[2rem] font-black text-gray-400 bg-gray-50 hover:bg-gray-100"
          >
            Cancel
          </button>
          <button 
            onclick={handleLogin}
            disabled={accessCode.length < 6}
            class="flex-[2] bg-blue-500 disabled:bg-gray-200 text-white py-6 rounded-[2rem] font-black text-2xl shadow-xl shadow-blue-200 active:scale-95 transition-all"
          >
            Go! 🚀
          </button>
        </div>
      </div>
    </div>
  {/if}
</div>

