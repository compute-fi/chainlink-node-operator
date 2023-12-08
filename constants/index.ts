import {
  createCampaign,
  dashboard,
  payment,
  profile,
  withdraw,
  arrow,
  admin,
  rank,
} from "../public";

export const navlinks = [
  {
    name: "Dashboard",
    imgUrl: dashboard,
    as: "/",
    path: "/",
    disabled: false,
    link: "/",
  },
  {
    name: "Campaign",
    imgUrl: createCampaign,
    as: "create-campaign",
    path: "/CreateCampaign",
    disabled: false,
    link: "/create-campaign",
  },
  {
    name: "Leaderboard",
    imgUrl: rank,
    as: "rank",
    path: "/Ranks",
    disabled: false,
    link: "/rank",
  },
  // {
  //   name: "Payment",
  //   imgUrl: payment,
  //   as: "payment",
  //   path: "/Payment",
  //   disabled: false,
  //   link: "/payment",
  // },
  // {
  //   name: "Withdraw",
  //   imgUrl: withdraw,
  //   as: "withdraw",
  //   path: "/Withdraw",
  //   disabled: false,
  //   link: "/withdraw",
  // },
  {
    name: "Profile",
    imgUrl: profile,
    as: "profile",
    path: "/Profile",
    disabled: false,
    link: "/profile",
  },
  // {
  //   name: "Admin",
  //   imgUrl: admin,
  //   as: "admin",
  //   path: "/Admin",
  //   disabled: false,
  //   link: "/admin",
  // },
  // {
  //   name: "logout",
  //   imgUrl: arrow,
  //   // link: "/",
  //   // disabled: true,
  // },
];