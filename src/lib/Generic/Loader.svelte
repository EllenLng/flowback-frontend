<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faSpinner } from '@fortawesome/free-solid-svg-icons/faSpinner';

	export let loading: boolean, Class:string = ""
</script>

<div class={`w-full relative ${loading && 'contrast-50'} ${Class}`}>
	<div
		class:hidden={!loading}
		class="conotrast-100 z-10 text-blue-500 absolute hidden left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2"
	>
		<Fa icon={faSpinner} spin={true} size="4x" />
	</div>
	<slot />
</div>
