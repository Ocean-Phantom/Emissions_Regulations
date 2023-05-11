# Emission Regulations

Like any company representative, the Engineer has regulations to follow regarding emissions. While the EPA(Environmental Polluting Agency) doesn't really care how much or how little your machines put in the air, they do specify that you're not allowed to take all of it back. After all, [Pollution is the Solution](https://mods.factorio.com/mod/Pollution_is_the_Solution). 

Note that the local populace has opinions about these regulations, claiming that [they speak for the trees](https://mods.factorio.com/mod/i-speak-for-the-trees-v2), using [biters to generate power](https://mods.factorio.com/mod/biter-power) is exploitative, and they don't like the [mining scars](https://mods.factorio.com/mod/MiningScars) you leave behind, and other such frivolous nonsense. They'll likely attempt to share their disagreements with you.  

# Info
This mod was made with the goal of limiting the amount of pollution you can remove by placing various pollution removal machines to encourage more variety and creativity than just building a wall of filters or just a regular defence wall.

This includes (but is not necessarily limited to) eligible entities added by the mods listed below. (Trees are not counted as eligible) They do this in one of two ways:
+ they emit a negative amount of pollution, such as Krastorio 2's Air Purifier
+ or they use scripting to remove pollution from chunk(s) around them, such as with the Air Suction Towers from Bery0za's Pureit

Emission Regulations should work with all mods that use the first type of machine automatically, but mods that implement the second type require a bit more work so feel free to request compat.

As of version 1.0.0, Emission Regulation offers 3 types of ways to limit how much pollution you can remove with machines, with an additional option to limit active machines to 1 per chunk. An graphing utility such as desmos may be useful if you wish to alter the values of the functions. **All limitations will calculate the max removable amount based on the amount of pollution currently present on the surface. In addition, each machine is assumed to be removing the maximum amount of pollution it can\*** As a result, poorly-placed machines may use up the 'pollution-absorbing capacity' allowed by the mod without actually absorbing that much pollution. 

*Testing has shown that the Air Suction Tower Mk2 & Mk3 from Bery0za's Pure it have a =cap on the amount of pollution they can remove which is lower than their theoretical maximum. The softcap is used instead.

A Linear limitation will simply allow you to remove a set percentage of your pollution.  
![](https://media.discordapp.net/attachments/822364847773712397/1106227836446060634/image.png?width=741&height=670)  
**For all images, the solid red line represents the total amount of pollution on the surface, while the black dashed line represents how much of it you are able to remove**  

An Exponential limitation is an upward trending exponential decay function represented by $$f(x)=(C ^ {D-1} \times x)^{\dfrac{1}{D}}$$  
While it will allow you to remove all of your pollution at first, past a certain point, less and less pollution will be removable relative to the total amount. The values of C and D are alterable.  
![](https://media.discordapp.net/attachments/822364847773712397/1106232160932868156/image.png?width=733&height=670)

The Logistic limitation is represented by $$f(x)=\dfrac{L}{1+e^{(\dfrac{k}{-x})(x-Z)}}$$  
Initially this limitation won't allow you any pollution removers, it will later go through a near exponential increase in the amount you are allowed, before eventually slowing its growth. The value of L is this functions asymptote, meaning its growth is capped and you won't be able to reach that amount of pollution removal or beyond. of  The values of L, k, and Z are alterable.  
![](https://media.discordapp.net/attachments/822364847773712397/1106238997400932552/image.png?width=741&height=670)

Tested to work with certain machines from the following mods:
- [Air Filtering](https://mods.factorio.com/mod/air-filtering)
- [Better Air Filtering](https://mods.factorio.com/mod/better-air-filtering)
- [Bery0za's Pure It](https://mods.factorio.com/mod/bery0zas-pure-it)
- [Hiladdar's Scrubbers](https://mods.factorio.com/mod/Hiladdar_Scrubbers)
- [Krastorio 2](https://mods.factorio.com/mod/Krastorio2)
- [k2 Air Purifier](https://mods.factorio.com/mod/k2-air-purifier)
- [Solid Waste Pollution Filter](https://mods.factorio.com/mod/solidwaste-pollution-filter)
- [TJ's Air Cleaner](https://mods.factorio.com/mod/TjAirCleaner)
- [Watered Air Purifier](https://mods.factorio.com/mod/AirPurifier)
Emission Regulation will technically work with any number of these installed simultaneously
**This mod has no special interactions with any of the mods mentioned in the topmost blurb.