<!-- Page: Landing -->
<script lang="ts">
  import { ArrowRight, Shield, Smile, Sparkles } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
</script>

<div class="flex flex-col items-center justify-center min-h-[85vh] text-center space-y-8 sm:space-y-12 md:space-y-16 px-4 py-8 sm:py-12" in:fade>
  <header class="space-y-4 sm:space-y-6">
    <div class="relative inline-block" in:fly={{ y: -20, duration: 800 }}>
      <div class="mx-auto w-24 h-24 sm:w-32 sm:h-32 bg-white rounded-[2rem] sm:rounded-[3rem] shadow-2xl flex items-center justify-center border-b-[8px] sm:border-b-[12px] border-blue-500 transform -rotate-3 transition-transform hover:rotate-0">
         <span class="text-4xl sm:text-6xl font-black italic text-blue-600">S</span>
      </div>
      <div class="absolute -top-2 -right-2 sm:-top-4 sm:-right-4 bg-yellow-400 p-2 sm:p-3 rounded-xl sm:rounded-2xl shadow-lg text-white animate-bounce">
        <Sparkles size={16} fill="currentColor" className="sm:w-6 sm:h-6" />
      </div>
    </div>
    
    <div class="space-y-2">
      <h1 class="text-4xl sm:text-5xl md:text-6xl font-black text-gray-900 tracking-tighter">SHAYOU</h1>
      <p class="text-lg sm:text-xl md:text-2xl text-blue-500 font-bold italic">Life Skills, Habits & fun! 🚀</p>
    </div>
    <p class="text-sm sm:text-base md:text-lg text-gray-400 max-w-xl mx-auto font-medium leading-relaxed">
      Beyond just savings—master good habits, ace your tasks, and play to learn real-world life skills. ✨
    </p>
  </header>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6 md:gap-8 w-full max-w-3xl px-2 sm:px-0">
    <a href="/login" class="group relative bg-white p-6 sm:p-8 md:p-10 rounded-2xl sm:rounded-3xl md:rounded-[3.5rem] shadow-lg sm:shadow-xl border-b-[8px] sm:border-b-[12px] border-blue-500 transition-all duration-300 hover:shadow-xl sm:hover:shadow-2xl hover:-translate-y-1 sm:hover:-translate-y-2 active:translate-y-0 active:border-b-2 sm:active:border-b-4 text-left flex flex-col gap-4 sm:gap-6">
      <div class="bg-blue-100 text-blue-600 p-3 sm:p-5 rounded-xl sm:rounded-[2rem] w-fit group-hover:rotate-12 transition-transform shadow-inner">
        <Shield size={28} className="sm:w-10 sm:h-10" />
      </div>
      <div class="space-y-1 sm:space-y-2">
        <h3 class="text-2xl sm:text-3xl font-black text-gray-800">Parents</h3>
        <p class="text-gray-500 font-bold text-sm sm:text-lg leading-snug">Assess habits, assign life-tasks, and guide their growth.</p>
      </div>
      <div class="mt-auto flex items-center gap-2 sm:gap-3 text-blue-600 font-black text-sm sm:text-xl">
        Parent Portal <ArrowRight size={18} className="sm:w-6 sm:h-6" />
      </div>
    </a>

    <a href="/kid/login" class="group relative bg-white p-6 sm:p-8 md:p-10 rounded-2xl sm:rounded-3xl md:rounded-[3.5rem] shadow-lg sm:shadow-xl border-b-[8px] sm:border-b-[12px] border-pink-500 transition-all duration-300 hover:shadow-xl sm:hover:shadow-2xl hover:-translate-y-1 sm:hover:-translate-y-2 active:translate-y-0 active:border-b-2 sm:active:border-b-4 text-left flex flex-col gap-4 sm:gap-6">
      <div class="bg-pink-100 text-pink-600 p-3 sm:p-5 rounded-xl sm:rounded-[2rem] w-fit group-hover:rotate-12 transition-transform shadow-inner">
        <Smile size={28} className="sm:w-10 sm:h-10" />
      </div>
      <div class="space-y-1 sm:space-y-2">
        <h3 class="text-2xl sm:text-3xl font-black text-gray-800">Kids</h3>
        <p class="text-gray-500 font-bold text-sm sm:text-lg leading-snug">Win games, build habits, and earn coins for your future!</p>
      </div>
      <div class="mt-auto flex items-center gap-2 sm:gap-3 text-pink-600 font-black text-sm sm:text-xl">
        Adventure Start <ArrowRight size={18} className="sm:w-6 sm:h-6" />
      </div>
    </a>
  </div>

  <footer class="pt-6 sm:pt-8 opacity-60">
    <p class="text-gray-400 font-black tracking-widest uppercase text-xs sm:text-sm">Made with Love for Families ❤️</p>
  </footer>
</div>

