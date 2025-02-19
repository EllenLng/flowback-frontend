<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import GroupFiltering from '$lib/Group/GroupFiltering.svelte';
	import GroupThumbnail from '$lib/Group/GroupThumbnail.svelte';
	import type { Group } from '$lib/Group/interface';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	let groupList: Group[] = [],
		status: StatusMessageInfo,
		filter: any = { joined: 'all', search: '' },
		loading = false;

	onMount(() => {
		getGroups();
	});

	const getGroups = async () => {
		loading = true;
		let urlFilter =
			filter.joined === 'member'
				? '&joined=true'
				: filter.joined === 'not-member'
				? '&joined=false'
				: '';

		urlFilter = `${urlFilter}&name__icontains=${filter.search}`;

		const { res, json } = await fetchRequest('GET', 'group/list?limit=1000' + urlFilter);
		status = statusMessageFormatter(res, json);

		if (!res.ok) return;

		groupList = json.results
			.reverse()
			.sort((group1: any, group2: any) => +group2.joined - +group1.joined);
		loading = false;
	};
</script>

<svelte:head>
	<title>Groups</title>
</svelte:head>

<Layout centering={true}>
	<!-- TODO: design of statusmessage is off -->
	<Loader bind:loading>
		<StatusMessage bind:status disableSuccess />
		<div class="flex flex-col items-center mt-6 gap-6 mb-6 w-full">
			{#if import.meta.env.VITE_DISABLE_GROUP_CREATION === 'false' || import.meta.env.VITE_DISABLE_GROUP_CREATION === undefined}
				<Button href="creategroup" Class="w-[40%] rounded-2xl">Create Group</Button>
			{/if}

			<GroupFiltering bind:filter {getGroups} />

			{#each groupList as group}
				<GroupThumbnail {group} />
			{/each}
		</div>
	</Loader>
</Layout>
