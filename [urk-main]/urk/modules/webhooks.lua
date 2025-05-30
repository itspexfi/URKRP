local webhooks = {
    -- general
    ['join'] = 'https://canary.discord.com/api/webhooks/1125371341277757561/SpS5dUhTsbr52j4kc_fWOAa_qkKilLE3yJppL-YJKKOXjnRiTwAO7Bc15FG5N02Cgzry',--done
    ['leave'] = 'https://canary.discord.com/api/webhooks/1125371448060551289/YnRMJn-kwToZHjXjroRHBPfY55GwKhPye3rPBWhaufH8UdKf6tce87MP7j71pqnpTHHk',--done
    -- civ
    ['give-cash'] = 'https://canary.discord.com/api/webhooks/1125371583427522650/ihxGrqbY9nnxpfEkeqPSp2txEwtwIZ3r32ykeGNJk66zgs-teMNwv1RyKxdPM_ezPA5d', --done
    ['bank-transfer'] = 'https://canary.discord.com/api/webhooks/1125371783231574026/u7UiiCftyGXn1vemT0GiJUZZXAOIXnxZ8zYObliymV3-Tk5K52UJ4TM3Gg696bXGMZ5W', --done
    ['search-player'] = 'https://canary.discord.com/api/webhooks/1125371896893034536/h2yXjTtaJ1qn-pqu7142qz0wC0vtRGJ6XenDI31Xc2C8FcdFyyxp1Ssjat9a1j_ykup3', --done
    ['ask-id'] = 'https://canary.discord.com/api/webhooks/1125371981638942720/t4IQuGHqkufWUWP8dGvf9HQiQDxYrcUs--bsC7_FuY1xKhimfRmkZo9SutcnMu8yXMJE',--done
    -- chat
    ['ooc'] = 'https://canary.discord.com/api/webhooks/1125372075809447937/hBjiPIokWveEmUzGZdRvSo6Y1fhXrlwmnSt-VM7TbunPwiXlymMThQrT9_ClL4kQBhJu', --done
    ['twitter'] = 'https://canary.discord.com/api/webhooks/1125372141391593532/ShLv4dvS3EMrf7XSn5cbVaKh2H1oDsMgbu_zWisMOfZC6lajFJfjbzercAH_UK082Vca', --done
    ['staff'] = 'https://canary.discord.com/api/webhooks/1125372234047950989/JCdxx4SEPAu1QZ0NKPpv9hELEsxZ4n6JlmuPtv6BUEz2iZ60d6_qzTdnRWFuCzfrilJJ',
    ['gang'] = 'https://canary.discord.com/api/webhooks/1125372327434125322/K8OWRJOxybOVFK0RpHSjsDKslA1iTP94MpeRlDI92DIdqw0Z4lnn3SxtGogRwCovBE9x',
    ['anon'] = 'https://canary.discord.com/api/webhooks/1125372412633034843/SOaVnSE9Rhfmg6Lr7_ZG4WkOZM_q2uJe_MZST4G1BKXy8C4wevwxCkwmKyTvI2D5ID76', --done
    -- admin menu
    ['kick-player'] = 'https://canary.discord.com/api/webhooks/1125744752546033804/miv673HmQ9_m9CafBgODPxjf38cZ5Xj6Dni3N3iR3yLPMWQiH0CI8hbEEl72zrah_AyI', --done --done
    ['ban-player'] = 'https://canary.discord.com/api/webhooks/1125744902152650752/Cm2hhiocMQ-JoW4sekhsj_uR_DJTk0qng6otNCgG4j1pev3QeRbFitktYMQT8iXAWsAb', --done
    ['spectate'] = 'https://canary.discord.com/api/webhooks/1125744905046732894/7qM7emTUVVgZrhWgBgLlqBnqYGkU1o5JjSjYdcV_5UKwXR11Sr6KqnU3Hb9r1b9dSP0i', --done
    ['revive'] = 'https://canary.discord.com/api/webhooks/1125744908184068116/jPZtIopTT1Kso97tgqWc7V6pcO92LJAgLkzBLI5cSgB33JTvoUhhKpx5JjWulxep7xnI', --done
    ['tp-player-to-me'] = 'https://canary.discord.com/api/webhooks/1125744909727580241/butjLNhA6Yx12gE2Ho4-qUuceJhY2dHzH1v8wfPqHk060QBGncv35g9KlDSd6ptSDuFv', --done
    ['tp-to-player'] = 'https://canary.discord.com/api/webhooks/1125744907341025321/os5ckvL9Np79eZKpsfHnqSMaP1sS1_rFGV3Y3Atf5yzknV9Ni5XSRIhRKdn50LyRUm9V', --done
    ['tp-to-admin-zone'] = 'https://canary.discord.com/api/webhooks/1125744911468216322/CH3iub6LlDYqB35Zk3XS-nzjVqWx10U8jTc6W_hkw6_qWmzalw7WrJxxW1xgYtnqraAz', --done
    ['tp-back-from-admin-zone'] = 'https://canary.discord.com/api/webhooks/1125744911468216322/CH3iub6LlDYqB35Zk3XS-nzjVqWx10U8jTc6W_hkw6_qWmzalw7WrJxxW1xgYtnqraAz', --done
    ['tp-to-legion'] = 'https://canary.discord.com/api/webhooks/1125744904174321786/S5ew34gpuSZ9yDkKxv7SZNHrq5R3-89PKaHlgrkThIjgaihVMHu9QIwO0JM7cai5sbnr', --done
    ['freeze'] = 'https://canary.discord.com/api/webhooks/1125744912428716082/yIwaUMStbuzxMsBMO9rTzTzuylj7uhiRkcsMI_NU9YHUr_Ej4b1xb_jDh76eiENky3YL', --done
    ['slap'] = 'https://canary.discord.com/api/webhooks/1125744913309511860/8gvELgK1Yp6ccwdfL_5_wTsEquYiwJ9TgQmqyKfjx9xflG5Wwotw4rRw2YyOlCKxbEY9', --done
    ['force-clock-off'] = 'https://canary.discord.com/api/webhooks/1125744914890768437/EYxZaXRFLEzE_0bpjT5QFYi77NNbPCp67jvFCmoLrC29GtuWNC_ZiVyaqwhVdugc8yvh', --done
    ['screenshot'] = 'https://discord.com/api/webhooks/1107148181478842379/91lfbTSBRfayreAYjgRZHAV_JVac4AJtVxBLugFclmpLSgYKanHDmNKNbGAjwJ_ndZ4j', --done
    ['video'] = 'https://canary.discord.com/api/webhooks/1125381888131989504/L2gh1AuuvwKC170RzgcJz0FfVQUHusFdOMZTn86HgBqM1nX6GoY60MHR2yjudlWxpkNS', --done
    ['group'] = 'https://canary.discord.com/api/webhooks/1125381966687117422/3Grdf5BfGO_SDISzqIa6wkG_FydgmF7vRYD71mtQYbG7NJTXlGs6PqtaJchzMlSkmohG', --done
    ['unban-player'] = 'https://canary.discord.com/api/webhooks/1125745956994940950/qp2LO2u9rOweS3PALBtUm3EgqTPdSeNyuLf2CqnurY-L04glaBkp3AVajFagGlu2Mcd8', --done
    ['remove-warning'] = 'https://canary.discord.com/api/webhooks/1125745959809327144/mS0R5EWwFXQGiKyw9HUmMimDLBn8h1fmEfTgQL34wOYqOzYiJb0B7cPyrci94RgxVUdw', --done
    ['add-car'] = 'https://canary.discord.com/api/webhooks/1125745957875744838/nLnI5LB7RVJ2yUo6KjNOAFiM6hsxaoi6GqbczWKXGk5-YIQJkflvkytOwt3VOGZqzFJR', --done
    ['manage-balance'] = 'https://canary.discord.com/api/webhooks/1125745961537372250/LJYTnkfHnDwu_soamseIG99HpFqJfwvU7UAcpcibcYD5AyzMXOoLplp5b2NA0nnow56S', --done
    ['ticket-logs'] = 'https://canary.discord.com/api/webhooks/1125746348990418974/P42gadIJBitg3E6yApf7G2wXOY3JKz3BrH6CkWLD1qeERbJrTIUo8tGRN0fdOpFbX6go',
    ['com-pot'] = 'https://canary.discord.com/api/webhooks/1125745961537372250/LJYTnkfHnDwu_soamseIG99HpFqJfwvU7UAcpcibcYD5AyzMXOoLplp5b2NA0nnow56S', --done
    -- vehicles
    ['crush-vehicle'] = 'https://canary.discord.com/api/webhooks/1125746482792898640/YxE5q4KcBdDJkROiKwDMiH3veBHa14zITBodlXAQSIR2opOghcTnE4worcqZgAm_GEV1', --done
    ['rent-vehicle'] = 'https://canary.discord.com/api/webhooks/1125746483732418621/DzLqNisLvvgzd0dRjTP9M0vSSs2Ej-FjO19g9V5roogCu2qgM0hl8m57ct64e2yxsu4i', --done
    ['sell-vehicle'] = 'https://canary.discord.com/api/webhooks/1125746485267529758/2nI_FnkWCjkAcojXsxY5WpHBJxLxJiiBlfGD7YX8oNkEUYLdm8qkPHwCU0vHxCyDxMaq', --done 
    -- mpd
    ['pd-clock'] = 'https://canary.discord.com/api/webhooks/1125747732720652338/u1M3e7np3l11yDCZdn0Ixfx0zz6AoTs76oaBXnJfJso7VS_JK2xI9VjkX6PJ3MABTux_',
    ['pd-afk'] = 'https://canary.discord.com/api/webhooks/1125747885141676072/-5eTXq3nsavCUEWxKnZIARCA8EXMp3-f2hYaK7uq2gGqXbb8BQw5Hr9e-BahvHYTJegQ',
    ['pd-armoury'] = 'https://canary.discord.com/api/webhooks/1125747800039247953/PJrAlgMfMc-E4GNMqV1014cIzBxHUg2FGXNazgRbQoEwyu_NrCKPpHdFMu2tuztZ6Fog',
    ['fine-player'] = 'https://canary.discord.com/api/webhooks/1125747657831362722/ncRElFtLT292mJGWEwWQ4vsMSpQ8yicbso5FKw9Z6vND-w3MX5KDu5kii0iH1vzYhcc9',
    ['jail-player'] = 'https://canary.discord.com/api/webhooks/1125747583835447316/Yr_U2ZLYbVDQjlvFChdOVwt8PJqdMLt5gsWv_ICqsRXM_58M1QJ8aGIativrCF0dpVi1',
    ['pd-panic'] = 'https://canary.discord.com/api/webhooks/1125747159845851166/krBMX3Joo9PEihNkRZoRdL-KhWoypMH1AchLmUzu75gwzMLScCiOPknRm-MUj9gbPVdr',
    ['seize-boot'] = 'https://canary.discord.com/api/webhooks/1125747972282515456/wKaZD1zOlgffYMgIe762oTclqp_xg7sYJf2jZ_m_Wn5ynyju4PVyrwAUwOtlXpOeuPCt',
    ['impound'] = 'https://canary.discord.com/api/webhooks/1125747038575935598/gi_Pamzo8dagyWiKukl_UwM4o2hOYv5eL_hpG7hpc_jtY82PPxW-lIqTlwRZppvXs8Vn',
    ['police-k9'] = 'https://canary.discord.com/api/webhooks/1125746952483655680/0M6xRMx24yLgUGB2v0yQeeyeamljb-sq17HkzG9ciL69t4i7z0ig3L6ElZV3j_HrMXMQ',
    -- nhs
    ['nhs-clock'] = 'https://discord.com/api/webhooks/1074465973781926058/fm0S75J4Fy45BXZ5GM31-JffRhsCuh4pVm12V8PmZxP2IQOUMyB4LTcRQwSzP96GtT8X',
    ['nhs-panic'] = 'https://discord.com/api/webhooks/1074466065486204948/uwMhaE-qPLeLYSSgjFOwJg6lSAtzWMcSjs7OfD4mgu-TpRSNUzWRFTdAsVs1bZeY6KXw',
    ['nhs-afk'] = 'https://discord.com/api/webhooks/1074466157958008842/LZX0Xjk5DcmGV075CGd6XDLsQTdIxg-vUBbJT1c0wUxHon4TNWQPFysLcvi10v5R7Lpe',
    ['cpr'] = 'https://discord.com/api/webhooks/1074466252375990313/kp8BkaaPG3XYHBKRddbUxqz8hCuDArTjSPviq2zWp7cVPaYi8aWbV7saY7qcdEAPB7Yw',
    -- licenses
    ['purchases'] = 'https://canary.discord.com/api/webhooks/1125744240526368848/y7Jh475W8YAPB9jFZYVLVEqK7d8gWzjsGtI6xx8F2J42B0WTrwPbOz-eLLCnxG5x2Eif', --done
    ['sell-to-nearest-player'] = 'https://canary.discord.com/api/webhooks/1125744240526368848/y7Jh475W8YAPB9jFZYVLVEqK7d8gWzjsGtI6xx8F2J42B0WTrwPbOz-eLLCnxG5x2Eif', --done
    -- casino
    ['blackjack-bet'] = 'https://canary.discord.com/api/webhooks/1125372774182027344/EcUG02uk1S7Thq-L7kQcJQUFqcsw-AIHlZft1r5hF-FAOumToEjxi9EMkLNEOpG864i1', --done 
    ['coinflip-bet'] = 'https://canary.discord.com/api/webhooks/1125372884068597841/6r-5hL9zPUm3gcTaCrjjpbPx5DZzRYXg5kVwMVnvGtUflEhP69EWZSQP2oped2pnnCH9', --done 
    ['purchase-chips'] = 'https://canary.discord.com/api/webhooks/1125372956881731635/Vc9RCHe3guBAW5jbPyeJfh36HXwkrH0Aux6lfdtdJ_OyGB10k00qdJl29NoQa_PWu7hA', --done 
    ['sell-chips'] = 'https://canary.discord.com/api/webhooks/1125373044173578280/16nbfcxOxq2IjaZA0TjOCkenEgemXlzOZEvB7d6Pptrs7ByE_oFGZeNqDQuYC_UphCok', --done 
    ['purchase-highrollers'] = 'https://canary.discord.com/api/webhooks/1125373127304691803/7hAVqw10S0Bcj0plhXLqXw_kpnfre3gYPmRJdzqv31rA_9-XoGeuGZ_oHuXua2hQraJf', --done 
    -- weapon shops
    ['weapon-shops'] = 'https://canary.discord.com/api/webhooks/1125744189733359697/i6hx0jRNUY9KY7iWmmV-2M1NIWl2yZ-nNNkQXuqsRsw2seSoyScfXbVwnVNpAVtozDAx', --done 
    -- housing (no logs atm)
    [''] = '',
    -- anticheat
    ['anticheat'] = 'https://canary.discord.com/api/webhooks/1125373392732831875/x6UW9FAQcUnCMfYzWlqTywRIUbttDL3aY5Y904N6egKL95m0xEMugcMCFTF9LoEbGbgS', --done
    ['ban-evaders'] = 'https://canary.discord.com/api/webhooks/1125373498316034179/ltFW8QFvzty91hXIywtoaonKLYF7bpZyTxQnLMaGjvNeh2RY4u8-CzQAA0iPVKqu_VoF', --done
    -- dono
    ['donation'] = 'https://canary.discord.com/api/webhooks/1125753085306875936/aKqKkfLsqqTgdOhl3kv92OB2xkIdYTTgXHbfyl0LNIcpW4vVAUmB9hUUTJ_JChkoi8_5',
    
    ['tutorial'] = 'https://canary.discord.com/api/webhooks/1125744172347961394/m2a2hEY0iuMPNJZGlixZie2Kah2_rKZyqidKH298q68iaB1fWjA8MXhQs0R7sHaD-wzT', -- done
}

local webhookQueue = {}
Citizen.CreateThread(function()
    while true do
        if next(webhookQueue) then
            for k,v in pairs(webhookQueue) do
                Citizen.Wait(100)
                if webhooks[v.webhook] ~= nil then
                    PerformHttpRequest(webhooks[v.webhook], function(err, text, headers) 
                    end, "POST", json.encode({username = "URK Logs", avatar_url = 'https://cdn.discordapp.com/attachments/1073970014081790043/1127767398041272361/78ea009835af7a672534fd36737ec6f9.png', embeds = {
                        {
                            ["color"] = 16448403,
                            ["title"] = v.name,
                            ["description"] = v.message,
                            ["footer"] = {
                                ["text"] = "URK - "..v.time,
                                ["icon_url"] = "",
                            }
                    }
                    }}), { ["Content-Type"] = "application/json" })
                end
                webhookQueue[k] = nil
            end
        end
        Citizen.Wait(0)
    end
end)
local webhookID = 1
function tURK.sendWebhook(webhook, name, message)
    webhookID = webhookID + 1
    webhookQueue[webhookID] = {webhook = webhook, name = name, message = message, time = os.date("%c")}
end

function URK.sendWebhook(webhook, name, message) -- used for other resources to send through webhook logs 
   tURK.sendWebhook(webhook, name, message)
end

function tURK.getWebhook(webhook)
    if webhooks[webhook] ~= nil then
        return webhooks[webhook]
    end
end