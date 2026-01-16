<!-- Reusable Modal Component -->
<script lang="ts">
  import { X } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';

  interface Props {
    visible: boolean;
    title: string;
    message: string;
    icon?: 'info' | 'success' | 'error' | 'warning';
    onClose?: () => void;
    children?: any;
  }

  let { visible = false, title = '', message = '', icon = 'info', onClose, children }: Props = $props();

  const iconColors = {
    info: 'bg-blue-100 text-blue-600 border-blue-400',
    success: 'bg-green-100 text-green-600 border-green-400',
    error: 'bg-red-100 text-red-600 border-red-400',
    warning: 'bg-yellow-100 text-yellow-600 border-yellow-400'
  };

  const iconSymbols = {
    info: 'ℹ️',
    success: '✅',
    error: '❌',
    warning: '⚠️'
  };

  function handleClose() {
    if (onClose) onClose();
  }

  function handleBackdropClick(e: MouseEvent) {
    if (e.target === e.currentTarget) {
      handleClose();
    }
  }
</script>

{#if visible}
  <div
    class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
    transition:fade={{ duration: 150 }}
    onclick={handleBackdropClick}
  >
    <div
      class="bg-white w-full max-w-md rounded-[2.5rem] p-8 shadow-3xl border-b-4 {iconColors[icon]}"
      in:fly={{ y: 30, duration: 250 }}
    >
      <div class="flex items-start justify-between mb-4">
        <div class="flex items-center gap-3">
          <div class="text-4xl">{iconSymbols[icon]}</div>
          <h2 class="text-2xl font-black text-gray-900">{title}</h2>
        </div>
        <button
          onclick={handleClose}
          class="text-gray-400 hover:text-gray-600 transition-colors"
        >
          <X size={24} />
        </button>
      </div>

      <p class="text-gray-600 font-bold mb-6 leading-relaxed">{message}</p>

      {#if children}
        <div class="mb-6">
          {@render children()}
        </div>
      {/if}

      <div class="flex gap-3">
        <button
          onclick={handleClose}
          class="w-full bg-blue-500 text-white py-3 rounded-xl font-black text-lg shadow-lg shadow-blue-100 hover:bg-blue-600 transition-colors active:scale-95"
        >
          OK
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  :global(html) {
    /* Prevent scrolling when modal is open */
  }
</style>
