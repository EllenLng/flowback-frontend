<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';
	import { onMount } from 'svelte';
	import TermsOfService from '$lib/Login/TermsOfService.svelte';

	export let sideHeaderOpen = false;

	let open_tos = false,
	 open_support = false,
	 open_tools = false;

	const logOut = () => {
		localStorage.removeItem('token');
		window.location.href = '/';
	};

	//TODO: Implement codocument creation
	const handleCoDocumentCreation = () => {};

	const closeWindowWhenClickingOutside = () => {
		
		window.addEventListener('click', function (e) {
			const notificationListElement = document.getElementById(`side-header`);
			if (
				sideHeaderOpen &&
				//@ts-ignore
				!notificationListElement?.contains(e.target)
			) {
				sideHeaderOpen = false;
			}
		});
	};

	const navs = [
		{
			title: 'User Profile',
			action: () => (window.location.href = '/user')
		},
		{ title: 'Support', action: () => (open_support = true) },
		{ title: 'TOS', action: () => (open_tos = true) },
		// { title: 'Tools', action: () => (open_tools = true) },
		{ title: 'Log Out', action: logOut }
	];

	onMount(() => {
		closeWindowWhenClickingOutside();
	});
</script>

<!-- TODO: Relative works great for phones -->
<div class:invisible={!sideHeaderOpen} class="absolute right-0 bg-white z-50 select-none shadow slide-animation" id="side-header" on:click={() => (sideHeaderOpen = !sideHeaderOpen)}>
	{#each navs as nav}
		<div
			class="cursor-pointer pt-3 pb-3 pr-10 pl-6 border-b border-gray-200 border hover:shadow hover:bg-blue-300 transition-shadow transition-colors"
			on:click={nav.action}
		>
			{$_(nav.title)}
		</div>
	{/each}
</div>

<Modal bind:open={open_support}>
	<div slot="header" class="p-4">
		{$_('Support')}
	</div>

	<div slot="body" class="text-left">
		<div>{$_('Phone support is only between 15:30 and 17:30 CET')}</div>
		<div>{$_('Number: +46737482562')}</div>
		<div>{$_(`Mail: ${import.meta.env.VITE_SUPPORT_MAIL}`)}</div>
		<!-- <div>{$_('For questions about Metamask, contact the Metamask team.')}</div> -->
	</div>
</Modal>

<Modal bind:open={open_tools}>
	<div slot="header" class="p-4">
		{$_('Tools')}
	</div>

	<div slot="body" class="text-center">
		<div class="py-3 mb-2">
			{$_(
				'Click this button to create a co-document, share the link for others to edit it. Remember to save the link.'
			)}
		</div>
		<div class="grupper-card row g-2 clickable">
			<div class="text-center my-2 noSelect">
				<div on:click={handleCoDocumentCreation}>+ {$_('Create Co-Document')}</div>
			</div>
		</div>
	</div>
</Modal>

<Modal bind:open={open_tos}>
	<div slot="body">
		<TermsOfService Class="!border-none !p-0 text-xs leading-7"/>
	</div>
</Modal>

<style>
	@keyframes slide-animation {
		from {
			right: -100px;
		}
		to {
			right: 0;
		}
	}

	.slide-animation {
		animation-name: slide-animation;
		animation-duration: 300ms;
	}
</style>
