<script lang="ts">
    import {Input, Button, InputAddon, ButtonGroup, Toggle, Spinner} from "flowbite-svelte";
    import {ArrowDownOutline, ArrowUpOutline} from "flowbite-svelte-icons";

    let {listener, edit = false} = $props();
    let latest_index = $state(listener.latest_index);
    let editing: boolean = $state(edit);
    let saving: boolean = $state(false);

    const propClass = "";

    const save = async () => {
        saving = true;
        const result = await fetch(`${import.meta.env.VITE_API_URL}/listeners/${listener.id}`, {
            method: "PUT",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({ latest_index })
        });
        saving = false;
        if (result.ok) {
            window.location.reload();
        } else {
            console.error(await result.text());
        }
    }
</script>

<div>
    <article class="p-4 m-2 border rounded-lg shadow bg-default">
        <heading class="flex justify-between">
            <h5 class="mb-4 text-xl font-medium">
                {#if listener.source }
                    <ArrowUpOutline class="inline"></ArrowUpOutline>
                {:else}
                    <ArrowDownOutline class="inline"></ArrowDownOutline>
                {/if}

                Subscription {listener.id}
            </h5>
            <span>
                <Toggle id="edit_listener_{listener.id}" bind:checked={editing}>Edit</Toggle>
            </span>
        </heading>
        <div class="flex">
            <div class="w-1/2">
                <ButtonGroup class={propClass}>
                    <InputAddon class="w-52">Id</InputAddon>
                    <Input value={listener.id} readonly></Input>
                </ButtonGroup>
                <ButtonGroup class={propClass}>
                    <InputAddon class="w-52">Source</InputAddon>
                    <Input value={listener.source} readonly></Input>
                </ButtonGroup>
                <ButtonGroup class={propClass}>
                    <InputAddon class="w-52">Service</InputAddon>
                    <Input value={listener.service} readonly></Input>
                </ButtonGroup>
                <ButtonGroup class={propClass}>
                    <InputAddon class="w-52">Model</InputAddon>
                    <Input value={listener.model} readonly></Input>
                </ButtonGroup>
                <ButtonGroup class={propClass}>
                    <InputAddon class="w-52">Subscriber</InputAddon>
                    <Input value={listener.subscriber} readonly></Input>
                </ButtonGroup>
                <ButtonGroup class={propClass}>
                    <InputAddon class="w-52">Synchronization Heartbeat</InputAddon>
                    <Input value={listener.synchronization_heartbeat} readonly></Input>
                </ButtonGroup>
                <ButtonGroup class={propClass}>
                    <InputAddon class="w-52">Synchronization In Progress</InputAddon>
                    <Input value={listener.synchronization_in_progress} readonly></Input>
                </ButtonGroup>
                <ButtonGroup class={propClass}>
                    <InputAddon class="w-52">Latest Index</InputAddon>
                    <Input type="number"
                           inputmode="numeric"
                           bind:value={latest_index} readonly={!editing}></Input>
                </ButtonGroup>
                <ButtonGroup class={propClass}>
                    <InputAddon class="w-52">Latest Outgoing Index</InputAddon>
                    <Input type="number" value={listener.latest_outgoing_index} readonly></Input>
                </ButtonGroup>
            </div>
            <div class="w-1/2">

            </div>
        </div>
        <div class="m-5 flex justify-end">
            <Button disabled={!editing || saving} onclick={() => { save(); }}>
                {#if saving}
                    <Spinner size="4" class="me-4"/>
                    Saving ...
                {:else}
                    Save
                {/if}
            </Button>
        </div>
    </article>
</div>
