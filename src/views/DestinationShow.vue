<template>
    <section v-if="destination" class="destination">
   <h1>{{destination.name}}</h1>
   <div class="destination-details">
    <img :src="`/images/${destination.image}`" :alt="destination.name">
    <p>{{destination.description}}</p>
   </div>
</section>
</template>
<script>
//import sourceData from '@/data.json'
import axios from 'axios'
export default{
    
    data() {
        return {
            destination:null 
        }
    },
    computed:{
        destinationId(){
            return parseInt( this.$route.params.id);
        },
        /*destination(){
            return sourceData.destinations.find(x=>x.id===this.destinationId);
        }*/
    },
     methods:{
      async  iniData(){
        try {
          const response = await axios.get(`http://travel-dummy-api.netlify.app/${this.$route.params.slug}.json`);
          this.destination= response.data;
           // Hacer algo con la respuesta
          } catch (error) {
            console.error(error);
          }
      }
    },
   async created(){
    this.iniData();
    this.$watch(
      ()=>this.$route.params,this.iniData()      

)
     
  },
 
    }
    
   

   
    

</script>