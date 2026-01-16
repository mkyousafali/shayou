<!-- Page: Kid Direct Login -->
<script lang="ts">
  import { KeyRound, Loader2, ArrowLeft } from 'lucide-svelte';
  import { fade, slide } from 'svelte/transition';
  import { supabase } from '$lib/supabase';
  import { goto } from '$app/navigation';

  let accessCode = '';
  let loading = false;
  let errorMessage = '';

  async function handleLogin() {
    if (accessCode.length !== 6) return;
    
    loading = true;
    errorMessage = '';

    try {
      // Find kid by access code
      const { data, error } = await supabase
        .from('kids')
        .select('id, family_id, name')
        .eq('access_code', accessCode)
        .single();

      if (error || !data) {
        errorMessage = 'Access code not found. Check your code and try again! 🤔';
      } else {
        // Store both family_id and kid_id
        localStorage.setItem('family_id', data.family_id);
        localStorage.setItem('kid_id', data.id);
        // Go directly to kid home
        goto(`/kid/${data.id}/home`);
      }
    } catch (e) {
      errorMessage = 'Something went wrong. Try again!';
      console.error(e);
    } finally {
      loading = false;
    }
  }

  function handleInputChange(e) {
    const value = e.target.value.toUpperCase().replace(/[^0-9A-Z]/g, '');
    accessCode = value.slice(0, 6);
  }
</script>

<div class="flex flex-col items-center justify-center min-h-[70vh] text-center space-y-8 px-4" in:fade>
  <div class="flex flex-col items-center gap-4">
    <div class="bg-pink-100 text-pink-600 p-5 rounded-[2rem] shadow-lg shadow-pink-100">
      <KeyRound size={48} />
    </div>
    <div class="space-y-1">
      <h1 class="text-4xl font-black text-gray-900 tracking-tight">Welcome Back! 👋</h1>
      <p class="text-gray-500 font-medium">Enter your 6-character access code ✨</p>
    </div>
  </div>

  {#if errorMessage}
    <div class="bg-red-50 text-red-500 px-6 py-3 rounded-2xl font-bold border-2 border-red-100 max-w-sm" transition:slide>
      {errorMessage}
    </div>
  {/if}

  <div class="w-full max-w-md space-y-6">
    <div class="space-y-3">
      <input
        type="text"
        placeholder="Enter your access code"
        value={accessCode}
        oninput={handleInputChange}
        maxlength="6"
        class="w-full px-6 py-4 text-center text-3xl font-bold tracking-widest uppercase border-2 border-pink-300 rounded-2xl focus:outline-none focus:border-pink-600 focus:ring-4 focus:ring-pink-100 transition-all"
        disabled={loading}
      />
      <p class="text-sm text-gray-500 font-medium">{accessCode.length} / 6 characters</p>
    </div>

    <button
      onclick={handleLogin}
      disabled={loading || accessCode.length !== 6}
      class="w-full py-4 bg-gradient-to-r from-pink-500 to-pink-600 text-white font-black text-lg rounded-2xl shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed transition-all active:scale-95 flex items-center justify-center gap-3"
    >
      {#if loading}
        <Loader2 size={24} class="animate-spin" />
        <span>Logging in...</span>
      {:else}
        <span>🚀 Let's Go!</span>
      {/if}
    </button>

    <button
      onclick={() => goto('/')}
      class="w-full py-3 text-pink-600 font-bold rounded-2xl hover:bg-pink-50 transition-all flex items-center justify-center gap-2"
    >
      <ArrowLeft size={20} /> Go Back Home
    </button>
  </div>

  <div class="max-w-md text-center space-y-3 mt-8 pt-8 border-t border-gray-200">
    <p class="text-gray-600 font-medium">
      💡 Your access code is unique to you. Don't share it with friends!
    </p>
    <p class="text-sm text-gray-500">
      Ask your parent if you don't remember your code.
    </p>
  </div>
</div>

<style>
  input::-webkit-outer-spin-button,
  input::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }

  input[type='number'] {
    -moz-appearance: textfield;
  }
</style>
