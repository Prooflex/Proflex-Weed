Config = {} -- Do not modify, may cause script issues

-- If you enable skillcheck, it will apply for all stages, the skill check chance can be a tiny bit buggy at high chances so dont go over 100.
Config.SkillCheck = true
Config.SkillCheckChance = 35
Config.Debug = true


-- Weed Picking
Config.Location = vector3(1557.04, 4442.2, 38.09) -- Define the location to spawn the Weed plants
-- This is a zone made for entering and leaving to make the props despawn and spawn as you enter and leave i recommend leaving this to 50 but if you want to change it feel free to 
-- I didnt want to do this but it was the only way to make the props spawn with server restart :(
Config.ZoneRadius = 50

-- Prop Customization
Config.Prop = "prop_weed_01" -- i left this as a customisable thing just incase you wanted to change the prop for something custom? or even a different type of weed prop
Config.PropAmount = 8 -- Define the amount of props you want to spawn
Config.PropRadius = 10 -- I recommend leaving this on 10 you can adjust it so the props are more spread out
Config.TargetDistance = 2 -- How close do you need to be to target the prop? This will cause issues if you make it to far away the player can stand at a certain distance and farm the same prop over and over without it being despawned. The actual distance for despawning the prop is 2.5
Config.PickingWeedTargetLang = 'Pick Weed' -- What do you want the target to say while targeting it?
Config.PickingWeedIcon = 'fas fa-seedling' -- what icon do you want the target to have?

-- Weed Event Customization
Config.EnabledScissors = true -- if you would like the player to require scissors in there inventory then turn this on
Config.ScissorsName = 'drug_scissors' -- What is the name of the scissors?
Config.AmountOfScissors = 1 -- how many sissors required to harvest the plant? 
Config.ScissorsNotFound = 'You need something to chop the cola off?' -- What do you want the notification to be if you dont have the scissors on you?
Config.WeedItem = "drug_weed" -- name of the item given to the player also the name of the item removed in drying
Config.WeedItemAmmount = math.random(1, 3) -- -- the amount given to the player
Config.PickingDuration = 4000 -- how long the player will be picking weed for? i made it so it match's the animation



Config.Dryingitem = "drug_weeddry"
Config.DryingItemAmmount = math.random(1, 3)
Config.DryingWeedAmmount = 2
Config.DryingDuration = 4000

Config.CuttingUpitem = "drug_weedcutup"
Config.CuttingUpItemAmmount = math.random(1, 3)
Config.CuttingWeedAmmount = 2
Config.CuttingUpDuration = 4000

Config.Baggingitem = "drug_weedbagged"
Config.BaggingItemAmmount = math.random(1, 3)
Config.BaggingWeedAmmount = 2
Config.BaggingRequiredBagItem = 'drug_bags'
Config.BaggingRequiredBagremove = math.random(1, 2)
Config.BaggingDuration = 4000



-- Language for progressCircle
Config.PickingLangauge = 'Harvesting Cola From the Plant...'
Config.DryingLangauge = 'Drying Weed...'
Config.CuttingUpLangauge = 'Cuting up Weed...'
Config.BaggingLangauge = 'Bagging Weed...'

-- Language for notifys
Config.notifyFail = 'You Failed Loser :('
Config.PickingWeedNotifyLang = 'Successfully harvested the weed..'
Config.DryingWeedNotifyLang = 'Weed dried..'
Config.CuttingUpWeedNotifyLang = 'You cut the weed up..'
Config.BaggedWeedNotifyLang = 'You bagged the weed..'
Config.ItemNotFound = 'The item required was not found in your pockets.'
Config.MissingScissorsNotify = 'Your missing something to chop it off.'

-- Third Eye Icons
Config.DryingWeedIcon = 'fas fa-sun'
Config.CuttingUpWeedIcon = 'fas fa-scissors'
Config.BaggedWeedTargetIcon = 'fas fa-bag-shopping'

-- Third Eye Language
Config.DryingWeedTargetLang = 'Dry Weed'
Config.CuttingUpWeedTargetLang = 'Cut Weed'
Config.BaggedWeedTargetLang = 'Bag Weed'
