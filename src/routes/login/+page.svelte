<!-- Page: Login -->
<script lang="ts">
  import { Shield, KeyRound, User, Heart, ChevronRight, Loader2 } from 'lucide-svelte';
  import { fade, slide } from 'svelte/transition';
  import { supabase } from '$lib/supabase';
  import { goto } from '$app/navigation';

  let mode = 'login'; // 'login' or 'register'
  let accessCode = '';
  let name = '';
  let relation = '';
  let confirmCode = '';
  let loading = false;
  let errorMessage = '';

  const relations = ['Mom', 'Dad', 'Guardian', 'Grandparent', 'Other'];

  async function handleLogin() {
    if (accessCode.length !== 6) return;
    loading = true;
    errorMessage = '';

    try {
      const { data, error } = await supabase
        .from('families')
        .select('*')
        .eq('access_code', accessCode)
        .single();

      if (error || !data) {
        errorMessage = 'Invalid Access Code. Please try again.';
      } else {
        // In a real app, we'd set a session cookie or use Supabase Auth
        localStorage.setItem('family_id', data.id);
        goto('/parent/dashboard');
      }
    } catch (e) {
      errorMessage = 'Something went wrong.';
    } finally {
      loading = false;
    }
  }

  async function handleRegister() {
    if (!name || accessCode.length !== 6 || accessCode !== confirmCode) {
      errorMessage = "Check your details and make sure codes match!";
      return;
    }
    
    loading = true;
    errorMessage = '';

    try {
      const { data, error } = await supabase
        .from('families')
        .insert([{ name, access_code: accessCode }])
        .select()
        .single();

      if (error) throw error;
      
      localStorage.setItem('family_id', data.id);
      goto('/parent/dashboard');
    } catch (e) {
      errorMessage = e.message;
    } finally {
      loading = false;
    }
  }
</script>

<div class="flex flex-col items-center justify-center min-h-[70vh] text-center space-y-8" in:fade>
  <div class="flex flex-col items-center gap-4">
    <div class="bg-blue-100 text-blue-600 p-5 rounded-[2rem] shadow-lg shadow-blue-100 italic transition-transform hover:scale-110">
      <Shield size={48} />
    </div>
    <div class="space-y-1">
      <h1 class="text-4xl font-black text-gray-900 tracking-tight">Parent Portal</h1>
      <p class="text-gray-500 font-medium">Keep your family's savings safe ✨</p>
    </div>
  </div>

  {#if errorMessage}
    <div class="bg-red-50 text-red-500 px-6 py-3 rounded-2xl font-bold border-2 border-red-100" transition:slide>
      {errorMessage}
    </div>
  {/if}

  <div class="w-full max-w-md glass rounded-[2.5rem] p-2 shadow-2xl border border-white/50">
    <!-- Tab Switcher -->
    <div class="flex p-2 gap-2 bg-gray-100/50 rounded-[2rem] mb-6">
      <button 
        onclick={() => { mode = 'login'; errorMessage = ''; }}
        class="flex-1 py-3 rounded-[1.5rem] font-bold transition-all {mode === 'login' ? 'bg-white text-blue-600 shadow-sm' : 'text-gray-500 hover:bg-white/50'}"
      >
        Sign In
      </button>
      <button 
        onclick={() => { mode = 'register'; errorMessage = ''; }}
        class="flex-1 py-3 rounded-[1.5rem] font-bold transition-all {mode === 'register' ? 'bg-white text-pink-600 shadow-sm' : 'text-gray-500 hover:bg-white/50'}"
      >
        Register
      </button>
    </div>

    <div class="px-8 pb-8 space-y-6">
      {#if mode === 'login'}
        <div class="space-y-6" in:slide>
          <div class="space-y-2 text-left">
            <label class="text-sm font-black text-gray-700 ml-2 uppercase tracking-widest flex items-center gap-2">
              <KeyRound size={16} class="text-blue-500" />
              Family Access Code
            </label>
            <input 
              type="text" 
              maxlength="6"
              bind:value={accessCode}
              placeholder="0 0 0 0 0 0" 
              class="w-full text-center text-3xl font-black tracking-[1em] px-4 py-5 rounded-3xl bg-gray-50 border-2 border-transparent focus:bg-white focus:border-blue-400 outline-none transition-all placeholder:text-gray-200" 
            />
            <p class="text-[10px] text-gray-400 text-center font-bold">ENTER YOUR 6-DIGIT CODE</p>
          </div>
          
          <button 
            onclick={handleLogin}
            disabled={loading || accessCode.length !== 6}
            class="w-full bg-blue-500 text-white font-black py-5 rounded-3xl hover:bg-blue-600 shadow-xl shadow-blue-200 transition-all active:scale-95 text-xl flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {#if loading}
              <Loader2 class="animate-spin" />
            {:else}
              Enter Dashboard <ChevronRight size={24} />
            {/if}
          </button>
        </div>
      {:else}
        <div class="space-y-5" in:slide>
          <!-- Name Input -->
          <div class="space-y-2 text-left">
            <label class="text-sm font-black text-gray-700 ml-2 uppercase tracking-widest flex items-center gap-2">
              <User size={16} class="text-pink-500" />
              Your Name
            </label>
            <input 
              type="text" 
              bind:value={name}
              placeholder="Parent Name" 
              class="w-full px-6 py-4 rounded-2xl bg-gray-50 border-2 border-transparent focus:border-pink-400 outline-none transition-all font-bold" 
            />
          </div>

          <!-- Relation Dropdown -->
          <div class="space-y-2 text-left">
            <label class="text-sm font-black text-gray-700 ml-2 uppercase tracking-widest flex items-center gap-2">
              <Heart size={16} class="text-red-500" />
              Relation
            </label>
            <select 
              bind:value={relation}
              class="w-full px-6 py-4 rounded-2xl bg-gray-50 border-2 border-transparent focus:border-pink-400 outline-none transition-all appearance-none cursor-pointer font-bold"
            >
              <option value="" disabled selected>Select relation...</option>
              {#each relations as r}
                <option value={r}>{r}</option>
              {/each}
            </select>
          </div>

          <!-- New Code -->
          <div class="space-y-2 text-left">
            <label class="text-sm font-black text-gray-700 ml-2 uppercase tracking-widest flex items-center gap-2">
              <KeyRound size={16} class="text-yellow-500" />
              Create Access Code
            </label>
            <input 
              type="text" 
              maxlength="6"
              bind:value={accessCode}
              placeholder="_ _ _ _ _ _" 
              class="w-full text-center text-xl font-bold tracking-[0.5em] px-4 py-4 rounded-2xl bg-gray-50 border-2 border-transparent focus:border-yellow-400 outline-none transition-all" 
            />
          </div>

          <!-- Re-enter Code -->
          <div class="space-y-2 text-left">
            <label class="text-sm font-black text-gray-700 ml-2 uppercase tracking-widest flex items-center gap-2 text-gray-400">
              Confirm Access Code
            </label>
            <input 
              type="text" 
              maxlength="6"
              bind:value={confirmCode}
              placeholder="_ _ _ _ _ _" 
              class="w-full text-center text-xl font-bold tracking-[0.5em] px-4 py-4 rounded-2xl bg-gray-50 border-2 border-transparent focus:border-gray-300 outline-none transition-all opacity-70" 
            />
          </div>

          <button 
            onclick={handleRegister}
            disabled={loading}
            class="w-full bg-pink-500 text-white font-black py-5 rounded-3xl hover:bg-pink-600 shadow-xl shadow-pink-200 transition-all active:scale-95 text-xl mt-4 flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {#if loading}
              <Loader2 class="animate-spin" />
            {:else}
              Create Account ✨
            {/if}
          </button>
        </div>
      {/if}
    </div>
  </div>

  <p class="text-sm text-gray-400 font-medium italic">
    Lost your code? <a href="/" class="text-pink-500 font-bold hover:underline">Go Back Home</a>
  </p>
</div>

