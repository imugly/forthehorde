local _G = getfenv(0);    -- Holds all the values WoW passes to us, like all the stat names
local abs = abs;          
local modName, L = ...;   -- mod name and mod-specific variables (like localization)

ForTheHorde = {};

-- Saved Variables
local gvif_opts,current_opts;

-- Triggers

local triggers = {
  { trigger = C_Spell.GetSpellName(90355),  spellId = 90335,  var_name = 'ancient_hysteria',           opt_name = "AncientHysteria",         gv = 'FTH_AH',  default = 1 },
  { trigger = C_Spell.GetSpellName(2825),   spellId = 2825,   var_name = 'bloodlust',                  opt_name = "Bloodlust",               gv = 'FTH_BL',  default = 1 },
  { trigger = C_Spell.GetSpellName(178207), spellId = 178207, var_name = 'drums_of_fury',              opt_name = "DrumsOfFury",             gv = 'FTH_DOF', default = 1 },
  { trigger = C_Spell.GetSpellName(230935), spellId = 230935, var_name = 'drums_of_the_mountain',      opt_name = "DrumsOfTheMountain",      gv = 'FTH_DOM', default = 1 },
  { trigger = C_Spell.GetSpellName(32182),  spellId = 32182,  var_name = 'heroism',                    opt_name = "Heroism",                 gv = 'FTH_H',   default = 1 },
  { trigger = C_Spell.GetSpellName(160452), spellId = 160452, var_name = 'netherwinds',                opt_name = "Netherwinds",             gv = 'FTH_NW',  default = 1 },
  { trigger = C_Spell.GetSpellName(80353),  spellId = 80353,  var_name = 'time_warp',                  opt_name = "TimeWarp",                gv = 'FTH_TW',  default = 1 },
  { trigger = C_Spell.GetSpellName(292686), spellId = 292686, var_name = 'mallet_of_thunderous_skins', opt_name = "MalletOfThunderousSkins", gv = 'FTH_MTS', default = 1 },
  { trigger = C_Spell.GetSpellName(256740), spellId = 256740, var_name = 'drums_of_the_maelstrom',     opt_name = "DrumsOfTheMaelstrom",     gv = 'FTH_DM',  default = 1 },
  { trigger = C_Spell.GetSpellName(309658), spellId = 309658, var_name = 'drums_of_deathly_ferocity',  opt_name = "DrumsOfDeathlyFerocity",  gv = 'FTH_DDM', default = 1 },
  { trigger = C_Spell.GetSpellName(390386), spellId = 390386, var_name = 'fury_of_the_aspects',        opt_name = "FuryOfTheAspects",        gv = 'FTH_FOA', default = 1 },
  { trigger = C_Spell.GetSpellName(264667), spellId = 264667, var_name = "primal_rage",                opt_name = "PrimalRage",              gv = 'FTH_PR',  default = 1 },
  { trigger = C_Spell.GetSpellName(383243), spellId = 342242, var_name = "time_anomaly",               opt_name = "TimeAnomaly",             gv = 'FTH_TA',  default = 1 },
};

-- Main Options Window
ForTheHorde.gvif = CreateFrame("Frame",modName,InterfaceFrameOptionsPanelContainer);
ForTheHorde.gvif.name = "For The Horde";
ForTheHorde.gvif:SetWidth( 500 );
ForTheHorde.gvif:SetHeight( 500 );

local chkbox_title = ForTheHorde.gvif:CreateFontString( nil, "Overlay", "GameFontNormalSmall" );
chkbox_title:SetHeight(20);
chkbox_title:SetJustifyH( "LEFT" );
chkbox_title:SetText( L["PLAY_SOUND_OPTS"] );
chkbox_title:SetPoint( "TOPLEFT", 10, -10 );

function createOptions( label, name, varName, x, y ) 
  local checkbox = CreateFrame( "CheckButton", name .. "_CheckBox_GlobalName", ForTheHorde.gvif, "InterfaceOptionsCheckButtonTemplate" );

  if ForTheHorde[varName] == 1 then
    checkbox:SetChecked(true);
  end
  getglobal(checkbox:GetName() .. 'Text'):SetText( label );
  checkbox:SetPoint( "TOPLEFT", x, y);
  checkbox:SetScript( "OnClick", 
    function() 
      if ForTheHorde[varName] == nil or ForTheHorde[varName] == 0 then
        ForTheHorde[varName] = 1;
      else
        ForTheHorde[varName] = 0;
      end
    end
  ); 
  return checkbox;
end

-- Register events that we listen for
ForTheHorde.gvif:RegisterEvent("ADDON_LOADED");
ForTheHorde.gvif:RegisterEvent("PLAYER_ENTERING_WORLD");
ForTheHorde.gvif:RegisterEvent("PLAYER_LOGOUT");
ForTheHorde.gvif:RegisterEvent("UNIT_AURA");

function ForTheHorde.gvif:OnEvent( event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 ) 
  if ( event == "UNIT_AURA" ) then
    if arg1 == "player" and arg2 ~= nil then 
      addedAuras = arg2["addedAuras"];
      if addedAuras ~= nil then
        for _,addedAura in ipairs(addedAuras) do
          for _,trigger_table in ipairs(triggers) do
            if ( addedAura["spellId"] == trigger_table["spellId"] and ForTheHorde['sound_on_' .. trigger_table["var_name"]] == 1 ) then
              local auraData, i, doTrigger = nil, 1, false;
              repeat 
                auraData = C_UnitAuras.GetBuffDataByIndex("player",i);
		if auraData ~= nil then
                  if ( auraData["spellId"] == trigger_table["spellId"] and auraData["duration"] - (auraData["expirationTime"] - GetTime()) < 1 ) then
                      doTrigger = true;
                    break 
                  end
                end
                i = i + 1;
              until( auraData == nil );

              if doTrigger then
                if FTH_SND_OVERRIDE ~= nil and FTH_SND_OVERRIDE == 1 then
                  PlaySoundFile( "Interface\\AddOns\\ForTheHorde\\bloodlust.mp3", "Master" );
                else
                  PlaySoundFile( "Interface\\AddOns\\ForTheHorde\\bloodlust.mp3" );
                end
		return
              end
            end
	  end
        end
      end
    end
  elseif event == "ADDON_LOADED" then
    if arg1 == modName then
      for _,trigger_table in ipairs(triggers) do
        if _G[trigger_table["gv"]] ~= nil then
          ForTheHorde['sound_on_' .. trigger_table["var_name"]] = _G[trigger_table["gv"]];
        else
          ForTheHorde['sound_on_' .. trigger_table["var_name"]] = trigger_table["default"];
        end
      end

      Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(ForTheHorde.gvif, "For The Horde"));

      --InterfaceOptions_AddCategory(ForTheHorde.gvif);
      local y = -40;
      for _,trigger_table in ipairs(triggers) do
        createOptions( trigger_table["trigger"], trigger_table["opt_name"], "sound_on_" .. trigger_table["var_name"], 10, y );
        y = y - 30;
      end
      

      y = y - 60;
      -- Sound override
      local chkbox_override = CreateFrame( "CheckButton","Override_CheckBox_GlobalName", ForTheHorde.gvif, "InterfaceOptionsCheckButtonTemplate" );
      if FTH_SND_OVERRIDE ~= nil and FTH_SND_OVERRIDE == 1 then
        chkbox_override:SetChecked(true);
      end
      getglobal(chkbox_override:GetName() .. 'Text'):SetText(  L["PLAY_SOUND_OVERRIDE"] );
      chkbox_override:SetPoint( "TOPLEFT", 10, y);
      chkbox_override:SetScript( "OnClick", 
        function() 
          if FTH_SND_OVERRIDE == nil or FTH_SND_OVERRIDE == 0 then
            FTH_SND_OVERRIDE = 1;
          else
            FTH_SND_OVERRIDE = 0;
          end
        end
      ); 
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    ForTheHorde["playerGuid"] = UnitGUID("player"); -- Get the player's GUID for comparison
  elseif event == "PLAYER_LOGOUT" then
    for _,trigger_table in ipairs(triggers) do
      _G[trigger_table["gv"]] = ForTheHorde['sound_on_' .. trigger_table["var_name"]];
    end
  end
end
ForTheHorde.gvif:SetScript("OnEvent",ForTheHorde.gvif.OnEvent);
