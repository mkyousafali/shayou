<!-- Page: Landing -->
<script lang="ts">
  import { ArrowRight, Shield, Smile, Sparkles } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
</script>

<div class="flex flex-col items-center justify-center min-h-[85vh] text-center space-y-16 px-4" in:fade>
  <header class="space-y-6">
    <div class="relative inline-block" in:fly={{ y: -20, duration: 800 }}>
      <div class="mx-auto w-32 h-32 bg-white rounded-[3rem] shadow-2xl flex items-center justify-center border-b-[12px] border-blue-500 transform -rotate-3 transition-transform hover:rotate-0">
         <span class="text-6xl font-black italic text-blue-600">S</span>
      </div>
      <div class="absolute -top-4 -right-4 bg-yellow-400 p-3 rounded-2xl shadow-lg text-white animate-bounce">
        <Sparkles size={24} fill="currentColor" />
      </div>
    </div>
    
    <div class="space-y-2">
      <h1 class="text-6xl font-black text-gray-900 tracking-tighter">SHAYOU</h1>
      <p class="text-2xl text-blue-500 font-bold italic">Life Skills, Habits & fun! 🚀</p>
    </div>
    <p class="text-xl text-gray-400 max-w-xl mx-auto font-medium leading-relaxed">
      Beyond just savings—master good habits, ace your tasks, and play to learn real-world life skills. ✨
    </p>
  </header>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-8 w-full max-w-3xl">
    <a href="/login" class="group relative bg-white p-10 rounded-[3.5rem] shadow-xl border-b-[12px] border-blue-500 transition-all duration-300 hover:shadow-2xl hover:-translate-y-2 active:translate-y-0 active:border-b-4 text-left flex flex-col gap-6">
      <div class="bg-blue-100 text-blue-600 p-5 rounded-[2rem] w-fit group-hover:rotate-12 transition-transform shadow-inner">
        <Shield size={40} />
      </div>
      <div class="space-y-2">
        <h3 class="text-3xl font-black text-gray-800">Parents</h3>
        <p class="text-gray-500 font-bold text-lg leading-snug">Assess habits, assign life-tasks, and guide their growth.</p>
      </div>
      <div class="mt-auto flex items-center gap-3 text-blue-600 font-black text-xl">
        Parent Portal <ArrowRight size={24} />
      </div>
    </a>

    <a href="/kid/select" class="group relative bg-white p-10 rounded-[3.5rem] shadow-xl border-b-[12px] border-pink-500 transition-all duration-300 hover:shadow-2xl hover:-translate-y-2 active:translate-y-0 active:border-b-4 text-left flex flex-col gap-6">
      <div class="bg-pink-100 text-pink-600 p-5 rounded-[2rem] w-fit group-hover:rotate-12 transition-transform shadow-inner">
        <Smile size={40} />
      </div>
      <div class="space-y-2">
        <h3 class="text-3xl font-black text-gray-800">Kids</h3>
        <p class="text-gray-500 font-bold text-lg leading-snug">Win games, build habits, and earn coins for your future!</p>
      </div>
      <div class="mt-auto flex items-center gap-3 text-pink-600 font-black text-xl">
        Adventure Start <ArrowRight size={24} />
      </div>
    </a>
  </div>

  <footer class="pt-8 opacity-60">
    <p class="text-gray-400 font-black tracking-widest uppercase text-sm">Made with Love for Families ❤️</p>
  </footer>
</div>

