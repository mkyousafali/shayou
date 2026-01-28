<!-- Page: Parent Dashboard -->
<script lang="ts">
  import { Users, CheckSquare, TrendingUp, AlertCircle, ArrowRight, Star, Loader2 } from 'lucide-svelte';
  import { fade, fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  let loading = $state(true);
  let familyId = $state('');
  let kids = $state<any[]>([]);
  let recentFeed = $state<any[]>([]);
  let stats = $state([
    { label: 'Waitlist', value: 0, icon: CheckSquare, color: 'blue' },
    { label: 'Kids Active', value: 0, icon: Users, color: 'pink' },
    { label: 'Habit Mastery', value: '0%', icon: Star, color: 'yellow' },
    { label: 'Requests', value: 0, icon: AlertCircle, color: 'red' },
  ]);

  onMount(async () => {
    const stored = localStorage.getItem('family_id');
    if (!stored) {
      window.location.href = '/login';
      return;
    }
    familyId = stored;
    await fetchData();
  });

  async function fetchData() {
    loading = true;
    try {
      // Fetch Kids
      const { data: kidsData, error: kidsError } = await supabase
        .from('kids')
        .select('*')
        .eq('family_id', familyId);

      if (kidsError) throw kidsError;
      kids = kidsData || [];

      // Update basic stats
      stats[1].value = kids.length;

      if (kids.length > 0) {
        const kidIds = kids.map(k => k.id);
        
        // Fetch pending tasks/requests count
        const { count: pendingCount, error: countError } = await supabase
          .from('tasks')
          .select('*', { count: 'exact', head: true })
          .in('kid_id', kidIds)
          .eq('status', 'pending');
        
        if (countError) {
          console.error('Error fetching pending count:', countError);
        } else {
          stats[3].value = pendingCount || 0;
        }

        // Fetch Recent Feed - only fetch for this family's kids
        const { data: allTasks, error: feedError } = await supabase
          .from('tasks')
          .select('*')
          .in('kid_id', kidIds)
          .order('created_at', { ascending: false })
          .limit(10);

        if (feedError) {
          console.error('Error fetching tasks feed:', feedError);
        } else if (allTasks) {
          const kidIds = new Set(kids.map(k => k.id));
          // Filter tasks for this family's kids and only include certain statuses
          recentFeed = allTasks
            .filter(t => kidIds.has(t.kid_id) && ['pending', 'completed'].includes(t.status))
            .slice(0, 5)
            .map(task => ({
              ...task,
              kids: { name: kids.find(k => k.id === task.kid_id)?.name }
            }));
        }
      }

    } catch (e) {
      console.error('Error fetching dashboard data:', e);
    } finally {
      loading = false;
    }
  }
</script>

<div class="space-y-8" in:fade>
  {#if loading}
    <div class="flex flex-col items-center justify-center py-20 gap-4 text-blue-500">
      <Loader2 size={48} class="animate-spin" />
      <p class="font-black italic">Loading family records...</p>
    </div>
  {:else}
    <header class="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-3 sm:gap-4 px-2 sm:px-0">
      <div>
        <h1 class="text-2xl sm:text-3xl md:text-4xl font-black text-gray-900 tracking-tight">Family Overview</h1>
        <p class="text-blue-500 font-bold italic text-xs sm:text-sm md:text-base">Life Skills & Future Leaders 🚀</p>
      </div>
      <div class="flex sm:hidden items-center gap-1 bg-yellow-100 text-yellow-700 px-3 py-1 rounded-xl font-black text-[10px] border-b-2 border-yellow-200 uppercase tracking-wider">
        <Star size={14} fill="currentColor" /> Mode
      </div>
      <div class="hidden sm:flex items-center gap-2 bg-yellow-100 text-yellow-700 px-4 py-2 rounded-2xl font-black text-xs sm:text-sm border-b-4 border-yellow-200 uppercase tracking-widest">
        <Star size={18} fill="currentColor" /> Assessment Mode
      </div>
    </header>

    <!-- Stats Grid -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-2 sm:gap-3 md:gap-4 px-2 sm:px-0">
      {#each stats as stat, i}
        <div 
          in:fly={{ y: 20, delay: i * 100 }}
          class="bg-white p-3 sm:p-4 md:p-6 rounded-xl sm:rounded-2xl md:rounded-[2.5rem] shadow-sm border-b-[6px] sm:border-b-4 border-{stat.color}-200 flex flex-col gap-2 hover:shadow-md transition-shadow"
        >
          <div class="bg-{stat.color}-50 text-{stat.color}-500 p-2 sm:p-3 rounded-lg sm:rounded-2xl w-fit">
            <stat.icon size={20} className="sm:w-6 sm:h-6" />
          </div>
          <div>
            <p class="text-xl sm:text-2xl font-black text-gray-900">{stat.value}</p>
            <p class="text-[10px] sm:text-xs font-bold text-gray-400 uppercase tracking-wider">{stat.label}</p>
          </div>
        </div>
      {/each}
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-3 sm:gap-4 md:gap-6 lg:gap-8 px-2 sm:px-0">
      <!-- Kids List -->
      <div class="lg:col-span-2 space-y-4 sm:space-y-6">
        <div class="flex items-center justify-between">
          <h2 class="text-xl sm:text-2xl font-black text-gray-800">Kid Accounts</h2>
          <a href="/parent/kids" class="text-xs sm:text-sm font-bold text-blue-500 hover:underline">View All</a>
        </div>
        
        <div class="space-y-3 sm:space-y-4">
          {#each kids as kid}
            <div class="bg-white p-4 sm:p-6 rounded-2xl sm:rounded-[3rem] shadow-sm border border-gray-100 flex items-center justify-between group hover:shadow-md transition-all">
              <div class="flex items-center gap-3 sm:gap-5 min-w-0">
                <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-lg sm:rounded-[1.5rem] bg-blue-100 flex items-center justify-center text-2xl sm:text-4xl shadow-inner group-hover:rotate-6 transition-transform flex-shrink-0">
                  {kid.avatar_url || '👤'}
                </div>
                <div class="min-w-0">
                  <h3 class="text-lg sm:text-xl font-black text-gray-800 truncate">{kid.name}</h3>
                  <div class="flex items-center gap-2 mt-1">
                    <span class="bg-yellow-50 text-yellow-600 px-2 sm:px-3 py-1 rounded-full text-[10px] sm:text-xs font-black whitespace-nowrap">🪙 {kid.balance}</span>
                  </div>
                </div>
              </div>
              <ArrowRight size={20} className="text-gray-300 group-hover:text-blue-500 group-hover:translate-x-1 transition-all flex-shrink-0" />
            </div>
          {:else}
            <div class="bg-gray-50 border-4 border-dashed border-gray-200 rounded-2xl sm:rounded-[3rem] p-8 sm:p-12 text-center text-gray-400">
               <p class="font-bold mb-4 text-sm sm:text-base">No kids added yet!</p>
               <a href="/parent/kids" class="bg-blue-500 text-white px-6 sm:px-8 py-2 sm:py-3 rounded-lg sm:rounded-2xl font-black shadow-lg shadow-blue-100 inline-block text-sm sm:text-base">Add Your First Kid</a>
            </div>
          {/each}
        </div>
      </div>

    <!-- Quick Activity -->
    <div class="bg-white p-4 sm:p-6 md:p-8 rounded-2xl md:rounded-[3.5rem] shadow-sm border-b-[6px] sm:border-b-[8px] md:border-b-[12px] border-red-100 flex flex-col justify-between">
      <div>
        <h2 class="text-lg sm:text-xl md:text-2xl font-black text-gray-800 mb-3 sm:mb-4 md:mb-6">Recent Feed</h2>
        <div class="space-y-2 sm:space-y-4 md:space-y-6">
          {#each recentFeed as activity}
            <div class="flex gap-3 sm:gap-4">
              <div class="w-1.5 sm:w-2 h-10 sm:h-12 {activity.status === 'pending' ? 'bg-yellow-400 animate-pulse' : 'bg-green-400'} rounded-full flex-shrink-0"></div>
              <div class="min-w-0">
                <p class="font-bold text-gray-800 text-sm sm:text-base break-words">{activity.kids?.name} {activity.status === 'pending' ? 'finished' : 'completed'} "{activity.title}"</p>
                <p class="text-[10px] sm:text-xs text-gray-400 font-bold uppercase">{new Date(activity.completed_at || activity.created_at).toLocaleTimeString()}</p>
              </div>
            </div>
          {:else}
            <p class="text-gray-400 font-bold italic py-4 text-sm">No recent activity yet! Quests will show up here.</p>
          {/each}
        </div>
      </div>
      <button class="w-full mt-6 sm:mt-8 bg-gray-50 text-gray-400 py-3 sm:py-4 rounded-2xl sm:rounded-3xl font-black hover:bg-gray-100 transition-colors uppercase text-[10px] sm:text-sm tracking-widest">
        Full History
      </button>
    </div>
  </div>

  <!-- Life Skills Assessment -->
  <section class="bg-indigo-900 rounded-2xl md:rounded-[4rem] p-4 sm:p-6 md:p-10 text-white shadow-2xl shadow-indigo-200 mx-2 sm:mx-0">
    <div class="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-3 sm:gap-4 lg:gap-6 mb-4 sm:mb-6 md:mb-10">
      <div>
        <h2 class="text-xl sm:text-2xl md:text-3xl font-black italic tracking-tight">Life Skills Assessment 🧠</h2>
        <p class="text-indigo-300 font-bold text-xs sm:text-sm md:text-base">How the kids are growing this week</p>
      </div>
      <button class="bg-white text-indigo-900 px-3 sm:px-6 md:px-8 py-2 sm:py-3 md:py-4 rounded-lg sm:rounded-xl md:rounded-2xl font-black text-xs sm:text-sm md:text-base shadow-lg hover:scale-105 transition-transform whitespace-nowrap">
        View Report
      </button>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-3 md:gap-4 lg:gap-6">
      <div class="bg-white/10 p-3 sm:p-4 md:p-6 lg:p-8 rounded-lg sm:rounded-xl md:rounded-[2.5rem] backdrop-blur-md border border-white/10 hover:bg-white/15 transition-colors">
        <h4 class="text-indigo-200 font-black uppercase text-[10px] sm:text-xs tracking-wider sm:tracking-widest mb-2 sm:mb-3 md:mb-4">Top Growth</h4>
        <p class="text-base sm:text-lg md:text-2xl font-black mb-1">Financial Literacy</p>
        <p class="text-green-400 font-bold text-xs sm:text-sm md:text-base">+15% improvement</p>
      </div>
      <div class="bg-white/10 p-3 sm:p-4 md:p-6 lg:p-8 rounded-lg sm:rounded-xl md:rounded-[2.5rem] backdrop-blur-md border border-white/10 hover:bg-white/15 transition-colors">
        <h4 class="text-indigo-200 font-black uppercase text-[10px] sm:text-xs tracking-wider sm:tracking-widest mb-2 sm:mb-3 md:mb-4">Habit Strength</h4>
        <p class="text-base sm:text-lg md:text-2xl font-black mb-1">Morning Routine</p>
        <p class="text-indigo-300 font-bold text-xs sm:text-sm md:text-base">Leo is 100% consistent!</p>
      </div>
      <div class="bg-white/10 p-3 sm:p-4 md:p-6 lg:p-8 rounded-lg sm:rounded-xl md:rounded-[2.5rem] backdrop-blur-md border border-white/10 hover:bg-white/15 transition-colors">
        <h4 class="text-indigo-200 font-black uppercase text-[10px] sm:text-xs tracking-wider sm:tracking-widest mb-2 sm:mb-3 md:mb-4">Action Needed</h4>
        <p class="text-base sm:text-lg md:text-2xl font-black mb-1">Room Tidiness</p>
        <p class="text-yellow-400 font-bold italic text-xs sm:text-sm md:text-base">Mina needs a reminder</p>
      </div>
    </div>
  </section>
  {/if}
</div>

