import Downloads, JSON

@testset "PokePastes" begin
    expected = """蕾冠王-Ice @ 吃剩的東西
Ability: As One (Glastrier)
Level: 50
EVs: 252 HP / 4 Atk / 252 Spe
爽朗 Nature
- 守住
- 雪矛
- 鐵壁
- 撲擊

鳳王 @ 弱點保險
Ability: 再生力
Level: 50
EVs: 252 HP / 4 Def / 164 SpA / 4 SpD / 84 Spe
內斂 Nature
IVs: 0 Atk
- 燃盡
- 空氣斬
- 大地之力
- 原始之力

雷丘 @ 氣勢披帶
Ability: 避雷針
Level: 50
EVs: 252 HP / 4 SpD / 252 Spe
膽小 Nature
- 擊掌奇襲
- 蹭蹭臉頰
- 伏特替換
- 怪異電波

熾焰咆哮虎 @ 腰木果
Ability: 威嚇
Level: 50
EVs: 244 HP / 12 SpD / 252 Spe
爽朗 Nature
- 擊掌奇襲
- 閃焰衝鋒
- 地獄突刺
- 拋下狠話

雷電雲 (M) @ 突擊背心
Ability: 不服輸
Level: 50
EVs: 76 HP / 140 Atk / 4 SpA / 172 Spe
急躁 Nature
- 瘋狂伏特
- 飛翔
- 蠻力
- 電網

多邊獸Ⅱ @ 進化奇石
Ability: 複製
Level: 50
EVs: 244 HP / 164 Def / 100 SpD
大膽 Nature
IVs: 0 Atk
- 怪異電波
- 自我再生
- 戲法空間
- 欺詐"""
    input = open(Downloads.download("https://pokepast.es/95c4a2af6731969b/json")) do fi
        JSON.parse(fi)
    end
    team = import_team(
        input["paste"],
        title = input["title"],
        author = input["author"],
        notes = input["notes"]
    ) 
    output = export_team(team, language = "zht")
    @test strip(output) == expected
end
