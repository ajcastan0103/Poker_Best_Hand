defmodule Poker do
    def deal(cards) do

        cards1 = [Enum.at(cards,0), Enum.at(cards,2), Enum.at(cards,4), Enum.at(cards,5), Enum.at(cards,6), Enum.at(cards,7), Enum.at(cards,8)]
        cards2 = [Enum.at(cards,1), Enum.at(cards,3), Enum.at(cards,4), Enum.at(cards,5), Enum.at(cards,6), Enum.at(cards,7), Enum.at(cards,8)]

        hand1=Enum.map(cards1, fn(x) -> {getRank(x), getSuit(x)} end)
        hand1=hand1|> List.keysort(0)
        hand2=Enum.map(cards2, fn(x) -> {getRank(x), getSuit(x)} end)
        hand2=hand2|> List.keysort(0)
        
        best1=bestHand(hand1)
        best2=bestHand(hand2)
        hand1Deck=elem(best1, 0)
        hand1Score=elem(best1, 1)
        hand2Deck=elem(best2, 0)
        hand2Score=elem(best2, 1)
        result= cond do
            hand1Score>hand2Score==true->convert(hand1Deck) 
            hand1Score<hand2Score==true->convert(hand2Deck)
            true->tie(hand1Deck,hand2Deck)

        end
        result      
    end
    
    def getRank(x) do
        ranks=[1,2,3,4,5,6,7,8,9,10,11,12,13,
        1,2,3,4,5,6,7,8,9,10,11,12,13,
        1,2,3,4,5,6,7,8,9,10,11,12,13,
        1,2,3,4,5,6,7,8,9,10,11,12,13]
        Enum.at(ranks,(x-1))
    end

    def getSuit(x) do
        suits=["C","C","C","C","C","C","C","C","C","C","C","C","C",
            "D","D","D","D","D","D","D","D","D","D","D","D","D",
            "H","H","H","H","H","H","H","H","H","H","H","H","H",
            "S","S","S","S","S","S","S","S","S","S","S","S","S" ]
        Enum.at(suits,(x-1))
    end

    def bestHand(hand) do
        hand=hand
        ranks=for i<-hand, do: elem(i,0)
        suits = for i<-hand, do: elem(i,1)
        suitCount = counter(suits) #get amounts of each suit
        rankCount = counter(ranks) #get amounts of each rank

        #Royal Flush 10
        royal=for i<-suitCount, do: if elem(i,1)>=5, do: royalFlush(elem(i,0),hand) 
        royal= Enum.find(royal, fn x -> is_list(x) end)

        #Straight Flush 9
        straightF=for i<-suitCount, do: if elem(i,1)>=5, do: straightFlush(elem(i,0),hand) 
        straightF= Enum.find(straightF,nil, fn x -> is_list(x) end)
        
        #Four of kind 8
        fourK= for i<-rankCount, do: if elem(i,1)==4, do: fourKind(elem(i,0),hand,[])
        fourK=Enum.find(fourK, fn x -> is_list(x) end)

        #Full House 7
        newRanks=for i<-rankCount, do: if elem(i,1) == 2 or elem(i,1) == 3 , do: i
        newRanks= Enum.reject(newRanks, fn x -> x==nil end)
        newRanks=for i<-newRanks, do: elem(i,0)
        fullH=fullHouse(newRanks,hand,[]) 
        fullH=Enum.filter(fullH, fn x -> x != nil end)
        a=(length(fullH)==5)
        
        #flush 6
        flush=for i<-suitCount, do: if elem(i,1)>=5, do: aFlush(elem(i,0),hand,[]) 
        flush=Enum.find(flush, fn x -> is_list(x) end)

        #straight 5
        straight=consecutive2(hand,[])

        #Three of kind 4
        threeK= for i<-rankCount, do: if elem(i,1)==3, do: threeKind(elem(i,0),hand,[])
        threeK=Enum.find(threeK, fn x -> is_list(x) end)

        #Two Pair 3
        newRanks2=for i<-rankCount, do: if elem(i,1) == 2, do: i
        newRanks2= Enum.reject(newRanks2, fn x -> x==nil end)
        newRanks2=for i<-newRanks2, do: elem(i,0)
        twoP=twoPair(newRanks2,hand,[]) 
        twoP=Enum.filter(twoP, fn x -> x != nil end)
        b=(length(twoP)==4)

        #Pair 2
        newRanks3=for i<-rankCount, do: if elem(i,1) == 2, do: i
        newRanks3= Enum.reject(newRanks3, fn x -> x==nil end)
        newRanks3=for i<-newRanks3, do: elem(i,0)
        pair=onePair(newRanks3,hand,[]) 
        pair=Enum.filter(pair, fn x -> x != nil end)
        c=(length(pair)==2)

        #high card
        high=highCard(ranks,suits)


        #Determine type of combo and return cards with score
        type=cond do
            is_list(royal)==true->{royal,10}
            is_list(straightF)==true->{straightF,9}
            is_list(fourK)==true->{Enum.reject(fourK, fn x -> x==nil end),8}
            a==true->{Enum.filter(fullH, fn x -> x != nil end),7}
            is_list(flush)==true and  is_list(royal)==false ->{flush,6}
            is_list(straight)==true->{straight,5}
            is_list(threeK)==true->{Enum.reject(threeK, fn x -> x==nil end),4}
            b==true-> {Enum.filter(twoP, fn x -> x != nil end),3}
            c==true-> {Enum.filter(pair, fn x -> x != nil end),2}
            true->{high,1}
        end
        type  
    end


    def counter(list) do
        a=list|>Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end) 
        Map.to_list(a)
    end

    def royalFlush(string,hand) do
        a=Enum.find(hand,100, fn x -> x=={1,string} end)
        b=Enum.find(hand,100, fn x -> x=={10,string} end)
        c=Enum.find(hand,100, fn x -> x=={11,string} end)
        d=Enum.find(hand,100, fn x -> x=={12,string} end)
        e=Enum.find(hand,100, fn x -> x=={13,string} end)
        new=[a,b,c,d,e]
        err=Enum.find(new, fn x -> x==100 end)
        if err==nil do
            new
        else
            nil
        end                
    end

    def straightFlush(string,hand) do
        ranks=for i<-hand, do: elem(i,0)
        suits = for i<-hand, do: elem(i,1)
        newRanks= onlySuit(hand,string,[])#ranks with most popular suit
        newRanks=Enum.reverse(newRanks)
        result = cond do
            length(newRanks)==5->consecutive(newRanks,0,[],string,1,length(newRanks))
             length(newRanks)==6->consecutive(newRanks,0,[],string,2,length(newRanks))
             length(newRanks)==7->consecutive(newRanks,0,[],string,2,length(newRanks))
            true->nil
        end
        result      
    end

    def onlySuit([], string,arr), do: arr
    def onlySuit([h | t], string,arr) do
        if elem(h,1)==string do
            onlySuit(t, string, arr++[elem(h,0)])
        else
            onlySuit(t, string,arr)
        end
    end
    
    def consecutive([h|t],0,_,_,_,_) when length([h|t])==3 do nil end
    def consecutive([h|t],0,_,_,_,_) when length([h|t])==4 do nil end
    def consecutive(_,4,arr,_,_,_), do: Enum.uniq(arr)
    def consecutive([],_,arr,_,_,_) when length(arr)!=5 do nil end
    def consecutive(_,_,_,_,0,_), do: nil
    def consecutive([h|t], counter, arr,string,tries,len) when arr>=5 do
        Enum.uniq(arr)
        if (h == (hd t) +1) do
            consecutive(t,counter+1,arr++[{h,string},{(hd t),string}],string,tries,len)
        else
            consecutive(t,0,[],string,tries-1,len)
        end
    end

    def fourKind(rank,hand,arr) do
        for i<-hand, do: if elem(i,0)==rank, do: arr++i
    end
   
   def fullHouse(ranks,_,_) when length(ranks)!=2 do [] end
   def fullHouse(_,_,arr) when length(arr)==5 do arr end
   def fullHouse(ranks,hand,arr) do
      for i<-hand, do: if Enum.member?(ranks,(elem(i,0)))==true , do: arr++i
    end

    def aFlush(_,_,arr) when length(arr)==5 do arr end
    def aFlush(suit,[h|t],arr) do
        if elem(h,1)==suit do
             aFlush(suit, t, arr++[{elem(h,0),suit}])
        else
            aFlush(suit, t,arr)
        end
    end
    
    def consecutive2(_,arr) when length(arr) == 5 do Enum.uniq(arr) end
    def consecutive2([],_) do nil end
    def consecutive2([h|t], arr) when length([h|t]) >= 2 and length(arr)<=5 do
        if elem(h,0) == elem((hd t),0)-1, do: 
            consecutive2(t,arr++[h]),
        else: 
            if arr != [], do: (if elem(List.last(arr),0) == elem(h,0)-1,
            do: consecutive2(t,arr++[h]), else: consecutive2(t,[])), 
            else: consecutive2(t,[])
    end
    def consecutive2(hand,arr) when length(hand) >= 1 do
        if length(arr) > 0, do: 
            (if elem(List.last(arr),0) == elem((hd hand),0)-1,
                do: consecutive2([],arr++[Enum.at(hand,0)])), 
            else: consecutive2([],arr)
    end
    
    def threeKind(rank,hand,arr) do
        for i<-hand, do: if elem(i,0)==rank, do: arr++i
    end

   def twoPair(ranks,_,_) when length(ranks)<2 do [] end
   def twoPair(_,_,arr) when length(arr)==4 do arr end
   def twoPair(ranks,hand,arr) do
      for i<-hand, do: if Enum.member?(ranks,(elem(i,0)))==true , do: arr++i
    end
   
   def onePair(ranks,_,_) when length(ranks)<1 do [] end
   def onePair(_,_,arr) when length(arr)==2 do arr end
   def onePair(ranks,hand,arr) do
      for i<-hand, do: if Enum.member?(ranks,(elem(i,0)))==true , do: arr++i
    end
     
    def highCard(rank,suit) do
        if Enum.at(rank,0)==1 do
            {Enum.at(rank,0),Enum.at(suit,0)}
        else
            {Enum.at(rank,7),Enum.at(suit,7)}
        end 
    end
    
    def tie(hand1,hand2) do
        ranks1=for i<-hand1, do: elem(i,0)
        ranks2=for i<-hand2, do: elem(i,0)
        if Enum.max(ranks1)>Enum.max(ranks2) or Enum.at(ranks1, 0)==1    do
            for i<- hand1, do: Enum.join(Tuple.to_list(i)) 
        else
            for i<- hand2, do: Enum.join(Tuple.to_list(i)) 
        end 
    end

    def convert(hand) do
        for i<- hand, do: Enum.join(Tuple.to_list(i)) 
    end

end