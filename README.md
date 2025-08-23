# dine

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

🚫 Remove These "Nice-to-Haves"
~~Order Verification & Fraud Prevention~~
~~SMS OTP~~ - Too complex, just take orders at face value
~~Address validation~~ - Let drivers figure it out
~~Duplicate prevention~~ - Not worth the complexity initially
~~Phone verification~~ - Just format validation
~~Advanced Customer Communication~~
~~SMS status updates~~ - Vendor calls when ready, that's it
~~Order tracking~~ - "Your order is being prepared" is enough
~~Backup contacts~~ - One phone number, keep it simple
~~Data Management Features~~
~~Order history lookup~~ - No accounts = no history needed
~~Customer preferences~~ - They can reorder manually if they want
~~Order analytics~~ - Focus on taking orders first
✅ Minimal Viable COD App Flow
Customer: Browse menu → Add to cart
Customer: Enter name, phone, address → Submit order
App: Show "Order received! Order #123. Vendor will call you."
Done. Vendor handles everything from there.

Order Placement:
Menu browsing
Cart functionality
Simple form: Name, Phone, Address
Order submission
Order Management (Vendor Side):
List of incoming orders
Mark order as "preparing" or "completed"
Customer phone number to call
Customer Confirmation:
Order number
"We'll call you soon" message
Maybe estimated time (30-45 minutes)
💡 This Removes All Complexity:
No accounts, no verification, no tracking, no notifications, no history, no fraud prevention.
Just: Order → Confirmation → Phone Call → Delivery → Payment
The beauty is in the simplicity. Customers get food, vendors get orders, money changes hands. Everything else is operational overhead that can be handled outside the app.
Keep it stupid simple. You can always add features later if the basic model works.


You're thinking in the right direction! Let me break this down to the **absolute simplest** approach:

## **🎯 Minimal Order Identification**

### **Option 1: Just Order Number (Simplest)**
- Give customer order number: `#DIN-1234`
- That's it. No lookup needed.
- If they need to check status, they call the restaurant with their order number

### **Option 2: Simple Order Lookup (Slightly Better)**
- **Order Number + Phone Number** combo for lookup
- One simple page: "Enter order # and phone to check status"
- No accounts, just these two pieces of info

## **🤔 Order Status: Call vs App**

### **Phone Call is Actually Better Because:**
- **Personal touch** - builds customer relationship
- **Real-time updates** - "Your food will be ready in 10 minutes"
- **Address clarification** - can confirm location details
- **Zero app complexity** - no status system to build
- **Works for everyone** - no need to check app

### **But if You Want Simple Status:**
Just **3 status levels**:
- ✅ "Order Received" 
- 🍳 "Being Prepared"
- 🚗 "Out for Delivery"

## **💡 My Recommendation: Keep It Phone-Based**

**Here's the dead simple flow:**

1. **Customer orders** → Gets order number `#DIN-1234`
2. **Email confirmation:** "Order #DIN-1234 received! We'll call you in 15-20 minutes."
3. **Vendor calls** when food is ready/being delivered
4. **Done.**

## **📧 Simple Email Setup**

```
Subject: Order Confirmation #DIN-1234

Hi [Name],

Your order has been received!

Order: #DIN-1234
Items: [list items]
Total: ₱[amount]
Delivery to: [address]

We'll call you at [phone] in 15-20 minutes with updates.

Thanks for ordering with Dine!
```

## **🗄️ Database: Just Store Everything**

```
Orders Table:
- order_id
- order_number (DIN-1234)
- customer_name  
- customer_phone
- customer_address
- items (JSON)
- total_amount
- status (received/preparing/delivered)
- created_at
```

**No complex lookup needed.** Vendor sees all orders in their dashboard, customer gets email confirmation, everyone's happy.

**The phone call handles everything else.** Keep the app for ordering, let human interaction handle the rest.

// Each vendor sees only their items
vendor1_items = order.items.where((item) => item['vendorId'] == 'vendor1')
// Result: [Pizza, Pasta]

vendor2_items = order.items.where((item) => item['vendorId'] == 'vendor2')  
// Result: [Burger]