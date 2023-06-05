<template>
    <div>
        <nav id="nav">
            <router-link id="logo" to="/">Vue School Travel App</router-link>
            <router-link  
            v-for="destination in destinations" 
              :to="{name:'destination.show',params:{id:destination.id,slug:destination.slug}}"
            :key="destination.id">
            {{destination.name}}
            
           </router-link>
          </nav>
        
    </div>
</template>
<style lang="css">
#nav .vue-school-active-link{
    color: rgb(255, 136, 0);
    border-bottom: 2px solid rgb(255, 217, 0);

}
</style>
<script>
import sourceData from '@/data.json'

export default{
  data(){
    return{
   destinations:sourceData.destinations}
  },
  
}
</script>