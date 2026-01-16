<!-- Page: Kid Request Spend -->
<script lang="ts">
  import { ShoppingBag, ChevronLeft, Send, Sparkles, Loader2 } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
  import { page } from '$app/state';
  import { supabase } from '$lib/supabase';
  import Modal from '$lib/components/Modal.svelte';

  const { kidId } = page.params;
  let amount = $state('');
  let reason = $state('');
  let loading = $state(false);
  let showErrorModal = $state(false);
  let errorMessage = $state('');
  let showSuccessModal = $state(false);

  async function sendRequest() {
    if (!amount || !reason) {
      errorMessage = 'Please enter how much and what for!';
      showErrorModal = true;
      return;
    }

    loading = true;
    try {
      const { error } = await supabase
        .from('spend_requests')
        .insert([{
          kid_id: kidId,
          item: reason,
          amount: parseInt(amount),
          status: 'pending'
        }]);

      if (error) throw error;

      showSuccessModal = true;
      setTimeout(() => {
        window.location.href = `/kid/${kidId}/home`;
      }, 1500);
    } catch (e) {
      console.error('Error sending request:', e);
      errorMessage = 'Could not send request. Please try again!';
      showErrorModal = true;
    } finally {
      loading = false;
    }
  }
</script>

<div class="space-y-6 pb-24" in:fade>
  <header class="flex items-center gap-4 py-4">
    <a href="/kid/{kidId}/home" class="p-3 bg-white rounded-2xl shadow-sm text-gray-500 hover:text-blue-500">
      <ChevronLeft size={24} />
    </a>
    <div>
      <h1 class="text-2xl font-black text-gray-900">Request Coins</h1>
      <p class="text-pink-500 font-bold text-sm italic">What are you saving for? ✨</p>
    </div>
  </header>

  <div class="bg-white p-8 rounded-[3rem] shadow-xl border-b-[12px] border-pink-400 space-y-8" in:fly={{ y: 20 }}>
    <div class="text-center space-y-4">
      <div class="inline-flex p-6 bg-pink-100 text-pink-500 rounded-[2.5rem] shadow-inner mb-2">
        <ShoppingBag size={48} />
      </div>
      <h2 class="text-xl font-black text-gray-800 uppercase tracking-widest">How much?</h2>
      <div class="relative inline-block">
        <span class="absolute left-0 top-1/2 -translate-y-1/2 text-4xl font-black text-yellow-500">🪙</span>
        <input 
          type="number" 
          bind:value={amount}
          placeholder="0" 
          class="bg-transparent text-center text-6xl font-black text-gray-900 w-48 outline-none border-b-4 border-gray-100 focus:border-pink-400 transition-all placeholder:text-gray-100" 
        />
      </div>
    </div>

    <div class="space-y-3">
      <label class="text-sm font-black text-gray-400 uppercase tracking-widest ml-4">What's it for?</label>
      <input 
        type="text" 
        bind:value={reason}
        placeholder="New Lego set, ice cream, toy..." 
        class="w-full bg-gray-50 p-6 rounded-[2rem] text-xl font-bold text-gray-800 border-2 border-transparent focus:bg-white focus:border-blue-400 outline-none transition-all placeholder:text-gray-200" 
      />
    </div>

    <button 
      onclick={sendRequest}
      disabled={loading}
      class="w-full bg-blue-500 text-white p-6 rounded-[2.5rem] text-2xl font-black shadow-xl shadow-blue-100 hover:scale-105 active:scale-95 transition-all flex items-center justify-center gap-3 disabled:opacity-50"
    >
      {#if loading}
        <Loader2 size={28} class="animate-spin" />
      {:else}
        Send to Parent <Send size={28} />
      {/if}
    </button>
  </div>

  <div class="text-center pt-4">
    <p class="text-gray-400 font-bold italic flex items-center justify-center gap-2">
      <Sparkles size={16} class="text-yellow-500" />
      They'll get a notification right away!
    </p>
  </div>

  <Modal
    visible={showErrorModal}
    title="Missing Information"
    message={errorMessage}
    icon="error"
    onClose={() => showErrorModal = false}
  />

  <Modal
    visible={showSuccessModal}
    title="Request Sent!"
    message={`Sent request for 🪙 ${amount} to Mom/Dad! ✨`}
    icon="success"
    onClose={() => showSuccessModal = false}
  />
</div>
