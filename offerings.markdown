---
layout: page
title: Offerings
permalink: /offerings/
---

## Current offerings

<div class="simpleCart_shelfItem">
  <h2 class="item_name">Masterclass in Biology - 11<sup>th</sup> Class</h2>
  <span class="item_price">₹ 1499</span>
  <a class="item_add razorPaymentGateway" href="javascript:;">Purchase</a>
</div>
<div class="simpleCart_shelfItem">
  <h2 class="item_name">Masterclass in Biology - 12<sup>th</sup> Class</h2>
  <span class="item_price">₹ 1499</span>
  <a class="item_add razorPaymentGateway" href="javascript:;">Purchase</a>
</div>
<div class="simpleCart_shelfItem">
  <h2 class="item_name">Bio Prodigy Test Series</h2>
  <span class="item_price">₹ 1999</span>
  <a class="item_add razorPaymentGateway" href="javascript:;">Purchase</a>
</div>

<link rel="stylesheet" href="/styles/custom.css">
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/simplecartjs/3.0.5/simplecart.min.js" integrity="sha512-EOuiE1YuBkhsjVlAEjRmjJbQa2phU+9s0akQHiXOp5Zs/ye429onMubcIKvSnLjeqt+ttFEkPwQFrMzJ6bg5rA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://code.jquery.com/jquery-3.7.1.slim.min.js" integrity="sha256-kmHvs0B+OpCW5GVHUNjv9rOmY0IvSIRcf7zGUDTDQM8=" crossorigin="anonymous"></script>
<script>
var options = {
  "key": "rzp_test_8nqzUjES33w76e", // Enter the Key ID generated from the Dashboard
  "amount": "1999", // Amount is in currency subunits. Default currency is INR. Hence, 50000 refers to 50000 paise
  "currency": "INR",
  "name": "A2Z Educational Services Private Limited", //your business name
  "description": "Masterclass in Biology Content",
  "image": "https://i.imgur.com/n5tjHFD.png",
  "order_id": "order_9A33XWu170gUtmSample", //This is a sample Order ID. Pass the `id` obtained in the response of Step 1
  "callback_url": "https://eneqd3r9zrjok.x.pipedream.net/",
  "prefill": { //We recommend using the prefill parameter to auto-fill customer's contact information especially their phone number
    "name": "Gaurav Kumar", //your customer's name
    "email": "gaurav.kumar@example.com",
    "contact": "9000090000" //Provide the customer's phone number for better conversion rates 
  },
  "notes": {
    "address": "Razorpay Corporate Office"
  },
  "theme": {
    "color": "#3399cc"
  }
};
$(document).ready(function() {
  $(".razorPaymentGateway").on("click", function(e){
    var rzp1 = new Razorpay(options);
    rzp1.open();
    e.preventDefault();
  });
});
</script>
