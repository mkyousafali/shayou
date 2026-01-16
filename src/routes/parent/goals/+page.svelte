<!-- Page: Parent Goals -->
<script lang="ts">
  import { Target, Plus, Heart, Sparkles } from 'lucide-svelte';
  import { fade } from 'svelte/transition';

  const goals = [
    { id: 1, kid: 'Leo', title: 'Lego Star Wars', current: 850, target: 1000, color: 'blue' },
    { id: 2, kid: 'Mina', title: 'New Bicycle', current: 200, target: 5000, color: 'pink' }
  ];
</script>

<div class="space-y-6" in:fade>
  <header class="flex justify-between items-center bg-white p-6 rounded-[2.5rem] shadow-sm border-b-4 border-blue-200">
    <div>
      <h1 class="text-3xl font-black text-gray-900">Family Goals</h1>
      <p class="text-blue-500 font-bold italic">Big dreams start small! 🎯</p>
    </div>
    <button class="bg-blue-500 text-white p-4 rounded-3xl shadow-lg hover:scale-105 active:scale-95 transition-transform">
      <Plus size={32} />
    </button>
  </header>

  <div class="space-y-4">
    {#each goals as goal}
      <div class="bg-white p-6 rounded-[2.5rem] shadow-sm border border-gray-100 space-y-4">
        <div class="flex justify-between items-center">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-{goal.color}-100 flex items-center justify-center text-{goal.color}-600 font-black">
              {goal.kid[0]}
            </div>
            <h3 class="font-black text-gray-800 text-xl">{goal.title}</h3>
          </div>
          <span class="font-bold text-gray-400">🪙 {goal.current} / {goal.target}</span>
        </div>
        
        <div class="w-full h-4 bg-gray-100 rounded-full overflow-hidden">
          <div class="h-full bg-{goal.color}-500" style="width: {(goal.current/goal.target)*100}%"></div>
        </div>
      </div>
    {/each}
  </div>
</div>
