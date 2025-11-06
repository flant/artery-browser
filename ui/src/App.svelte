<script lang="ts">
  import "./app.css";
  import {Card, Navbar, NavBrand, DescriptionList, List} from "flowbite-svelte";

  const fetchJson = async (url: string) => {
     const response = await fetch(url);
     return response.json();
  }
</script>

<main>
   <Navbar>
      <NavBrand href="/">
         <span class="self-center whitespace-nowrap text-xl font-semibold dark:text-white">
             Artery Browser
         </span>
      </NavBrand>
   </Navbar>

   {#await fetchJson('http://localhost:3000/artery/subscriptions')}
      <p>Loading...</p>
   {:then data}
      {#each data as subscription}
         <Card size="lg" class="p-4 text-center sm:p-8 md:p-10 m-2">
            <div class="mr-2">
               <code>{subscription.path}</code>
            </div>
            <List tag="dl" class="divide-y">
               <div class="flex flex-row pb-3 place-content-between">
                  <DescriptionList tag="dt">Service</DescriptionList>
                  <DescriptionList tag="dd">{subscription.route.service}</DescriptionList>
               </div>
               <div class="flex flex-row pb-3 place-content-between">
                  <DescriptionList tag="dt">Model</DescriptionList>
                  <DescriptionList tag="dd">{subscription.route.model}</DescriptionList>
               </div>
               <div class="flex flex-row pb-3 place-content-between">
                  <DescriptionList tag="dt">Action</DescriptionList>
                <DescriptionList tag="dd">{subscription.route.action}</DescriptionList>
               </div>
               <div class="flex flex-row pb-3 place-content-between">
                  <DescriptionList tag="dt">Plural</DescriptionList>
                  <DescriptionList tag="dd">{subscription.route.plural}</DescriptionList>
               </div>
            </List>
         </Card>
      {/each}
   {:catch error}
      <p>{error.message}</p>
   {/await}
</main>

<style>

</style>
