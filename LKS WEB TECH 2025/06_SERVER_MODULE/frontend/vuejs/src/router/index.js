import { createRouter,createWebHistory } from "vue-router";
import IndexPage from '../components/IndexPage.vue'
import DashboardPage from '../components/dashboard/IndexPage.vue'
import ShowPage from '../components/installment/showPage.vue'
import LisrCars from '../components/installment/ListCarsPage.vue'
import DataValidationPage from '../components/data_validation/CreatePage.vue'

const routes = [
    {
        path: "/",
        name: "Index",
        component: IndexPage,
        meta: {title: 'Home'}
    },
    {
        path: "/dashboard",
        name: "Dashboard",
        component: DashboardPage,
        meta: {title: 'Home'}
    },
    {
        path: "/show",
        name: "ShowPage",
        component: ShowPage,
        meta: {title: 'List Cars in Central Jakarta'}
    },
    {
        path: "/list",
        name: "LisrCars",
        component: LisrCars,
        meta: {title: 'List Cars in Central Jakarta'}
    },
    {
        path: "/data",
        name: "DataValidationPage",
        component: DataValidationPage,
        meta: {title: 'Request Data Validation'}
    },
];

const router = createRouter({
    history: createWebHistory(),
    routes
})

export default router