// Name: Dhruva Kashyap Shastry
// Matriculation Number: G2502233L
use NoSQL_IA

//Q1. How many product categories are there? For each product category, show the number of records.
db.baristacoffeesalestbl.aggregate([{
    $group:{_id:"$product_category", records:{$sum:1}
}])

//Q2. What is the average caffeine per beverage type (coffee/tea/energy drink)?
db.caffeine_intake_tracker.aggregate([
  {
    $project: {
      beverage: {
        $switch: {
          branches: [
            { case: { $eq: ["$beverage_coffee", "True"] }, then: "coffee" },
            { case: { $eq: ["$beverage_energy_drink", "True"] }, then: "energy_drink" },
            { case: { $eq: ["$beverage_tea", "True"] }, then: "tea" }
          ],
          default: "none"
        }
      },
      caffeine_mg: 1
    }
  },
  {
    $group: {
      _id: "$beverage",
      avg_caffeine: { $avg: "$caffeine_mg" },
      count: { $sum: 1 }
    }
  }
])

//Q3. How does sleep impact rate vary by time of day (morning/afternoon/evening)?
db.caffeine_intake_tracker.aggregate([
  {
    $project: {
      time_of_day: {
        $switch: {
          branches: [
            { case: { $eq: ["$time_of_day_afternoon", "True"] }, then: "afternoon" },
            { case: { $eq: ["$time_of_day_evening", "True"] }, then: "evening" },
            { case: { $eq: ["$time_of_day_morning", "True"] }, then: "morning" }
          ],
          default: "none"
        }
      },
      sleep_impacted: 1
    }
  },
  {
    $group: {
      _id: "$time_of_day",
      impacted_rate: { $avg: "$sleep_impacted" },
      n: { $sum: 1 }
    }
  }
])

//Q4. Bucket caffeine into Low/Med/High and compare average sleep quality
db.caffeine_intake_tracker.aggregate(
[
    {
        $bucket: {
            groupBy: "$caffeine_mg",
            boundaries: [ 0, 0.25, 0.5, 1.01 ],
            default: "unknown",
            output: {
                "avg_sleep_quality" : { $avg: "$sleep_quality" },
                "avg_focus" : { $avg: "$focus_level" },
                "n": { $sum: 1 }
            }
        }
    },
    {
        $addFields: {
            caffeine_band:{
                $switch: {
                    branches: [
                        { case: {$eq:["$_id",0]}, then: "Low" },
                        { case: {$eq:["$_id",0.25]}, then: "Medium" },
                        { case: {$eq:["$_id",0.5]}, then: "High" }
                    ],
                    default: "unknown"
                }
            }
        }
    },
    {
        $project: {
            _id: 0, caffeine_band: 1, n: 1, avg_sleep_quality: 1, avg_focus: 1
        }
    }
]
)

//Q5. What is the total revenue and order count?
db.coffeesales.aggregate(
[{
        $addFields: {
            money_num: {$toDouble: "$money"}
        }
    },
    {
        $group: {_id: null, order: {$sum: 1}, revenue: {$sum: "$money_num"}
        }
    },
    {
        $project: {
            _id: 0, order: 1, revenue: 1
        }
    }
])

//Q6. Which drink is most cash-heavy? (cash share by drink)
db.coffeesales.aggregate(
[{
        $addFields: {
            is_cash: {$eq:["$cash_type","cash"]}, money_num: {$toDouble: "$money"}
        }
    },
    {
        $group: {
            _id: "$coffee_name", total_orders: {$sum: 1}, total_revenue: {$sum: "$money_num"}, cash_orders: {$sum: {$cond:["$is_cash",1,0]}}, cash_revenue: {$sum: {$cond:["$is_cash","$money_num",0]}}
        }
    },
    {
        $project: {
            _id: 0,
            coffee_name: "$_id",
            cash_order_share: {$divide: ["$cash_orders","$total_orders"]},
            cash_revenue_share: {$divide: ["$cash_revenue","$total_revenue"]}
        }
    }
])