<!-- Page: Kid Find Family -->
<script lang="ts">
  import { Search, Loader2 } from 'lucide-svelte';
  import { fade, slide } from 'svelte/transition';
  import { supabase } from '$lib/supabase';
  import { goto } from '$app/navigation';

  let familyCode = '';
  let loading = false;
  let errorMessage = '';

  async function handleFindFamily() {
    if (familyCode.length !== 6) return;
    
    loading = true;
    errorMessage = '';

    try {
      // Find family by access code
      const { data, error } = await supabase
        .from('families')
        .select('id, name')
        .eq('access_code', familyCode)
        .single();

      if (error || !data) {
        errorMessage = 'Family code not found. Ask your parent for the code! 🤔';
      } else {
        // Store family_id so we can load kids
        localStorage.setItem('family_id', data.id);
        // Go to kid select page
        goto('/kid/select');
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
    familyCode = value.slice(0, 6);
  }
</script>

<div class="flex flex-col items-center justify-center min-h-[70vh] text-center space-y-8 px-4" in:fade>
  <div class="flex flex-col items-center gap-4">
    <div class="bg-pink-100 text-pink-600 p-5 rounded-[2rem] shadow-lg shadow-pink-100 animate-bounce">
      <Search size={48} />
    </div>
    <div class="space-y-1">
      <h1 class="text-4xl font-black text-gray-900 tracking-tight">Find Your Family</h1>
      <p class="text-gray-500 font-medium">Ask your parent for the 6-character family code ✨</p>
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
        placeholder="Enter 6-character family code"
        value={familyCode}
        oninput={handleInputChange}
        maxlength="6"
        class="w-full px-6 py-4 text-center text-2xl font-bold tracking-widest uppercase border-2 border-pink-300 rounded-2xl focus:outline-none focus:border-pink-600 focus:ring-4 focus:ring-pink-100 transition-all"
        disabled={loading}
      />
      <p class="text-sm text-gray-500 font-medium">{familyCode.length} / 6 characters</p>
    </div>

    <button
      onclick={handleFindFamily}
      disabled={loading || familyCode.length !== 6}
      class="w-full py-4 bg-gradient-to-r from-pink-500 to-pink-600 text-white font-black text-lg rounded-2xl shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed transition-all active:scale-95 flex items-center justify-center gap-3"
    >
      {#if loading}
        <Loader2 size={24} class="animate-spin" />
        <span>Finding...</span>
      {:else}
        <span>Find My Family</span>
      {/if}
    </button>

    <button
      onclick={() => history.back()}
      class="w-full py-3 text-pink-600 font-bold rounded-2xl hover:bg-pink-50 transition-all"
    >
      ← Go Back
    </button>
  </div>

  <div class="max-w-md text-center space-y-4 mt-8 pt-8 border-t border-gray-200">
    <p class="text-gray-600 font-medium">
      Don't have a family code? Your parent can create one when they set up the parent portal.
    </p>
    <p class="text-sm text-gray-500">
      If you need help, ask a parent to check their settings! 👨‍👩‍👧‍👦
    </p>
  </div>
</div>

<style>
  /* Remove number spinner from input */
  input::-webkit-outer-spin-button,
  input::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }

  input[type='number'] {
    -moz-appearance: textfield;
  }
</style>
