<!-- Page: Habit World -->
<script lang="ts">
  import { ShieldCheck, ShieldAlert, Sparkles, Trophy, Gamepad2, ArrowLeft, Brain, ThumbsUp, ThumbsDown } from 'lucide-svelte';
  import { fade, fly, slide } from 'svelte/transition';
  import { spring } from 'svelte/motion';

  // Habit Categories
  const habitLessons = [
    {
      id: 'brushing',
      title: 'Diamond Smile',
      description: 'Brush twice a day for a healthy glow!',
      type: 'good',
      reward: 50,
      icon: ShieldCheck,
      color: 'blue'
    },
    {
      id: 'clutter',
      title: 'The Mess Monster',
      description: 'Leaving toys on the floor makes the monster grow.',
      type: 'bad',
      reward: 20,
      icon: ShieldAlert,
      color: 'red'
    },
    {
      id: 'vegetables',
      title: 'Power Veggies',
      description: 'Green veggies give you super strength!',
      type: 'good',
      reward: 40,
      icon: ShieldCheck,
      color: 'pink'
    }
  ];

  let selectedHabit = $state(null);

  function selectHabit(habit) {
    selectedHabit = habit;
  }
</script>

<div class="space-y-8 pb-20" in:fade>
  <!-- Header -->
  <div class="flex items-center gap-4">
    <button onclick={() => window.history.back()} class="bg-white p-4 rounded-[1.5rem] shadow-sm text-gray-400 hover:text-blue-500 transition-colors">
      <ArrowLeft size={24} />
    </button>
    <div>
      <h1 class="text-4xl font-black text-gray-900 italic tracking-tight">Habit World 🌎</h1>
      <p class="text-gray-500 font-bold">Learn, Play, and Grow!</p>
    </div>
  </div>

  {#if !selectedHabit}
    <!-- Main Habit Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8" in:fly={{ y: 20 }}>
      {#each habitLessons as habit (habit.id)}
        <button 
          onclick={() => selectHabit(habit)}
          class="text-left group relative bg-white rounded-[3rem] p-8 shadow-xl border-b-[12px] transition-all hover:-translate-y-2 active:scale-95
                 {habit.color === 'blue' ? 'border-blue-400' : ''}
                 {habit.color === 'red' ? 'border-red-400' : ''}
                 {habit.color === 'pink' ? 'border-pink-400' : ''}"
        >
          <div class="flex items-start justify-between">
            <div class="{habit.type === 'good' ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'} p-5 rounded-[2rem] mb-4">
              <habit.icon size={40} />
            </div>
            <div class="bg-yellow-50 px-4 py-2 rounded-2xl border border-yellow-100">
              <span class="text-yellow-600 font-black">🪙 {habit.reward}</span>
            </div>
          </div>
          <h3 class="text-2xl font-black text-gray-900 mb-2">{habit.title}</h3>
          <p class="text-gray-500 font-bold text-lg">{habit.description}</p>
          
          <div class="mt-6 flex items-center gap-2 text-blue-500 font-black uppercase text-sm tracking-widest opacity-0 group-hover:opacity-100 transition-opacity">
            Unlock Lesson <ArrowLeft size={16} class="rotate-180" />
          </div>
        </button>
      {/each}

      <!-- Game Tile -->
      <div class="bg-yellow-400 rounded-[3rem] p-8 text-white shadow-xl shadow-yellow-100 border-b-[12px] border-yellow-600 relative overflow-hidden group col-span-1 md:col-span-2">
        <div class="relative z-10">
          <h2 class="text-4xl font-black mb-4 italic tracking-tighter">Habit Hero Games</h2>
          <p class="text-xl font-bold mb-8">Defeat the distraction monsters and earn massive coins!</p>
          <button class="bg-white text-yellow-600 font-black px-10 py-5 rounded-[2rem] text-xl shadow-lg hover:scale-105 active:scale-95 transition-all flex items-center gap-3">
            <Gamepad2 size={28} />
            Play Now
          </button>
        </div>
        <div class="absolute right-10 bottom-0 opacity-20 translate-y-4 group-hover:translate-y-0 transition-transform">
          <Brain size={280} />
        </div>
      </div>
    </div>
  {:else}
    <!-- Detail Lesson View -->
    <div class="bg-white rounded-[4rem] p-12 shadow-2xl border-b-[16px] {selectedHabit.color === 'blue' ? 'border-blue-400' : selectedHabit.color === 'red' ? 'border-red-400' : 'border-pink-400'}" in:slide>
      <div class="flex flex-col items-center text-center space-y-8">
        <div class="p-8 rounded-[3rem] {selectedHabit.type === 'good' ? 'bg-green-50 text-green-500' : 'bg-red-50 text-red-500'} scale-125">
          <selectedHabit.icon size={80} />
        </div>
        
        <div>
          <h2 class="text-5xl font-black text-gray-900 mb-4">{selectedHabit.title}</h2>
          <p class="text-2xl text-gray-600 font-bold max-w-2xl mx-auto">
             {selectedHabit.type === 'good' 
              ? "This is a Super Habit! Doing this makes you stronger and earns you coins." 
              : "Watch out! This is a Clutter Habit. It takes away your energy and time."}
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-3xl">
          <div class="bg-gray-50 p-8 rounded-[3rem] border-2 border-dashed border-gray-200">
            <ThumbsUp size={48} class="text-green-500 mx-auto mb-4" />
            <h4 class="font-black text-xl mb-2">Why it's Good</h4>
            <p class="text-gray-500 font-bold">Helps you grow big and strong!</p>
          </div>
          <div class="bg-gray-50 p-8 rounded-[3rem] border-2 border-dashed border-gray-200">
            <ThumbsDown size={48} class="text-red-500 mx-auto mb-4" />
            <h4 class="font-black text-xl mb-2">The Downside</h4>
            <p class="text-gray-500 font-bold">Makes learning more difficult.</p>
          </div>
        </div>

        <div class="flex gap-4 w-full">
          <button 
            onclick={() => selectedHabit = null}
            class="flex-1 bg-gray-100 text-gray-500 font-black py-6 rounded-[2.5rem] text-xl transition-all hover:bg-gray-200"
          >
            Go Back
          </button>
          <button 
            onclick={() => { alert('Quiz Started!'); selectedHabit = null; }}
            class="flex-[2] bg-blue-500 text-white font-black py-6 rounded-[2.5rem] text-2xl shadow-xl shadow-blue-200 hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-3"
          >
            <Trophy size={28} />
            Start Challenge
          </button>
        </div>
      </div>
    </div>
  {/if}

  <!-- Progress Tracker -->
  <div class="bg-blue-50 rounded-[3rem] p-8 border-2 border-blue-100 flex items-center justify-between">
    <div class="flex items-center gap-4">
      <div class="bg-blue-500 text-white p-4 rounded-2xl">
        <Sparkles size={24} />
      </div>
      <div>
        <p class="text-blue-900 font-black text-xl italic tracking-tight">Habit Master Rank</p>
        <p class="text-blue-600 font-bold uppercase text-sm tracking-widest">Level 2: Skill Seeker</p>
      </div>
    </div>
    <div class="text-right">
      <p class="text-blue-900 font-black text-2xl">120/500 XP</p>
      <div class="w-48 h-3 bg-blue-200 rounded-full mt-2 overflow-hidden shadow-inner">
        <div class="h-full bg-blue-500 w-[24%] rounded-full shadow-[0_0_10px_rgba(59,130,246,0.5)]"></div>
      </div>
    </div>
  </div>
</div>
