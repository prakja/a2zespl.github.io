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
<script type="text/javascript" src="https://checkout.razorpay.com/v1/razorpay.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/simplecartjs/3.0.5/simplecart.min.js" integrity="sha512-EOuiE1YuBkhsjVlAEjRmjJbQa2phU+9s0akQHiXOp5Zs/ye429onMubcIKvSnLjeqt+ttFEkPwQFrMzJ6bg5rA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://code.jquery.com/jquery-3.7.1.slim.min.js" integrity="sha256-kmHvs0B+OpCW5GVHUNjv9rOmY0IvSIRcf7zGUDTDQM8=" crossorigin="anonymous"></script>
<script type="text/javascript">
$(document).ready(function() {
  // Single instance on page.
  var razorpay = new Razorpay({
    key: 'rzp_test_8nqzUjES33w76e	',
    // logo, displayed in the payment processing popup
    image: 'https://i.imgur.com/n5tjHFD.png',
  });

  // Fetching the payment.
  razorpay.once('ready', function(response) {
    console.log(response.methods);
  });

  // Submitting the data.
  var data = {
    amount: 1999, // in currency subunits. Here 1000 = 1000 paise, which equals to ₹10
    currency: "INR", // Default is INR. We support more than 90 currencies.
    email: 'test.appmomos@gmail.com',
    contact: '9123456780',
    notes: {
      address: 'Ground Floor, SJR Cyber, Laskar Hosur Road, Bengaluru',
    },
    // order_id: '123',
    method: 'netbanking',
    // method specific fields
    bank: 'HDFC'
  };

  $(".razorPaymentGateway").click(function() {
    alert("Payment clicked");
    // has to be placed within a user-initiated context, such as click, in order for popup to open.
    razorpay.createPayment(data);

    razorpay.on('payment.success', function(resp) {
      alert("Payment success.");
      alert(resp.razorpay_payment_id);
      alert(resp.razorpay_order_id);
      alert(resp.razorpay_signature);
    }); // will pass payment ID, order ID, and Razorpay signature to success handler.

    razorpay.on('payment.error', function(resp) {
      alert(resp.error.description);
    }); // will pass error object to error handler
  });
});
</script>
