load "cassels_flynn.m";
load "dave.m";
Attach("GSp.m");
X := GSpLattice(4,3,0);

G := ConformalSymplecticGroup(4,GF(3));
CC := ConjugacyClasses(G);
ZG := Subgroups(G);

SG := SymplecticGroup(4,GF(3));
possible_subs := [];
for i := 1 to #ZG do
    H := ZG[i]`subgroup;
    for x in H do
	if Order(x) eq 2 and not x in SG then
	    Append(~possible_subs,i);
	    break;
	end if;
    end for;
end for;

U, incl := UnitGroup(GF(3));
chi := hom<G -> U | [Identity(U),Identity(U),U.1]>;
sigs := [];
CCG := ConjugacyClasses(G);
for i := 1 to #CCG do
    x := CCG[i][3];
    sigx := <[incl(chi(x)), Trace(x)], Dimension(Kernel(Matrix(x) - Identity(G)))>;
    if not sigx in sigs then
	Append(~sigs,sigx);
    end if;
end for;

function sigstat(H);
    sigstatH := [0/1 : i in [1..#sigs]];
    CCH := ConjugacyClasses(H);
    for i := 1 to #CCH do
	x := CCH[i][3];
	sigx := <[incl(chi(x)), Trace(x)], Dimension(Kernel(Matrix(x) - Identity(G)))>;
	n := Index(sigs,sigx);
	sigstatH[n] := sigstatH[n] + CCH[i][2]/#H;
    end for;
    return sigstatH;
end function;

all_sigstats := [];
subs_with_sigstat := [];
for i := #possible_subs to 1 by -1 do
    ii := possible_subs[i];
    H := ZG[ii]`subgroup;
    dat := sigstat(H);
    bool1 := false;
    for j := 1 to #subs_with_sigstat do
	jj := subs_with_sigstat[j][1][1];
	H2 := ZG[jj]`subgroup;
	if dat eq sigstat(H2) then
	    bool1 := true;
	    bool2 := false;
	    for k := 1 to #subs_with_sigstat[j] do
		jjj := subs_with_sigstat[j][k][1];
		H3 := ZG[jjj]`subgroup;
		if IsConjugate(GL(4,GF(3)),H,H3) then
		    subs_with_sigstat[j][k] := subs_with_sigstat[j][k] cat [ii];
		    bool2 := true;
		    break;
		end if;
	    end for;
	    if not bool2 then
		subs_with_sigstat[j] := subs_with_sigstat[j] cat [[ii]];
	    end if;
	    break;
	end if;
    end for;
    if not bool1 then
	Append(~all_sigstats,dat);
	Append(~subs_with_sigstat,[[ii]]);
    end if;
end for;

function mindist_nthsigstat(n);
    V := VectorSpace(RealField(),18);
    mindist := 1;
    for j := 1 to #all_sigstats do
	if j ne n then
	    mindist := Minimum(mindist,Norm(V ! all_sigstats[j] - V ! all_sigstats[n]));
	end if;
    end for;
    return mindist/2;
end function;

allmindists := [mindist_nthsigstat(n) : n in [1..#all_sigstats]];

function allvalidsigs(sig);
    validsigs := [];
    for i := 1 to #sig do
	if sig[i] ne 0 then
	    Append(~validsigs,i);
	end if;
    end for;
    return validsigs;
end function;

// ##########################################################################################################

// function to compute dimension of rational three torsion subgroup of Jacobian of a given curve

function dim_rationalthreetors(definingpols);
    C := HyperellipticCurveOfGenus(2,definingpols[1]+definingpols[2]^2/4);
    Jac := Jacobian(C);
    Kum := KummerSurface(Jac);
    zeropt := Kum ! 0;

    hompols, affpols := eqns_2PequalsnegativeP(Rationals(),definingpols);
    A16<k1,k2,k3,k4,f0,f1,f2,f3,f4,f5,f6,alpha,l1,l2,l3,l4> := PolynomialRing(RationalField(),16);
    A5<k1,k2,k3,k4,alpha> := PolynomialRing(Rationals(),5);
    projec1 := hom<A16 -> A5 | [A5.i : i in [1..4]] cat [0 : i in [1..7]] cat [A5.5] cat [0 : i in [1..4]]>;
    A4<K1,K2,K3,K4> := PolynomialRing(Rationals(),4);
    projec2 := hom<A5 -> A4 | [A4.i : i in [1..4]] cat [0]>;
    temppols1 := [projec1(hompols[1])] cat [Resultant(projec1(hompols[j-1]), projec1(hompols[j]), alpha) : j in [3..#hompols]];
    temppols2 := [projec2(temppols1[j]) : j in [1..#temppols1]];

    P3 := ProjectiveSpace(Rationals(),3);
    X := Scheme(P3,temppols2);
    Xpts := RationalPoints(X);
    count := 0;
    for Xpt in Xpts do
	kumpt := Kum ! Eltseq(Xpt);
	if 3*kumpt eq zeropt then
	    possible_points := Points(Jac, kumpt);
//	    print #possible_points;
	    count := count + #possible_points;
	end if;
    end for;

    return Valuation(count,3);
end function;


// function to compute dimension of Jac(C)[3](Q(sqrt(-3))

function dim_cyclotomicthreetors(definingpols);
    C := HyperellipticCurveOfGenus(2,definingpols[1]+definingpols[2]^2/4);
    Q3 := CyclotomicField(3);
    Jac := BaseExtend(Jacobian(C),Q3);
    Kum := KummerSurface(Jac);
    zeropt := Kum ! 0;

    hompols, affpols := eqns_2PequalsnegativeP(Rationals(),definingpols);
    A16<k1,k2,k3,k4,f0,f1,f2,f3,f4,f5,f6,alpha,l1,l2,l3,l4> := PolynomialRing(RationalField(),16);
    A5<k1,k2,k3,k4,alpha> := PolynomialRing(Rationals(),5);
    projec1 := hom<A16 -> A5 | [A5.i : i in [1..4]] cat [0 : i in [1..7]] cat [A5.5] cat [0 : i in [1..4]]>;
    A4<K1,K2,K3,K4> := PolynomialRing(Rationals(),4);
    projec2 := hom<A5 -> A4 | [A4.i : i in [1..4]] cat [0]>;
    temppols1 := [projec1(hompols[1])] cat [Resultant(projec1(hompols[j-1]), projec1(hompols[j]), alpha) : j in [3..#hompols]];
    temppols2 := [projec2(temppols1[j]) : j in [1..#temppols1]];

    P3 := ProjectiveSpace(Q3,3);
    X := Scheme(P3,temppols2);
    Xpts := RationalPoints(X);
    count := 0;
    for Xpt in Xpts do
	kumpt := Kum ! Eltseq(Xpt);
	if 3*kumpt eq zeropt then
	    possible_points := Points(Jac, kumpt);
//	    print #possible_points;
	    count := count + #possible_points;
	end if;
    end for;

    return Valuation(count,3);
end function;


// function to compute maximum dimension of a subgroup of Jac(C)[3] defined over a degree n number field.

function monicintegralpol(p);
    P<x> := Parent(p);
    degp := Degree(p);
    p := p/Coefficient(p,degp);
    for i := 1 to degp do
	ai := Denominator(Coefficient(p,degp-i));
	if ai ne 1 then
	    facai := Factorisation(ai);
	    ci := &*[fac[1]^(Ceiling(fac[2]/i)) : fac in facai];
	    p := Evaluate(p,x/ci)*ci^degp;
	    if LCM([Denominator(Coefficient(p,j)) : j in [0..degp-1]]) eq 1 then
		break;
	    end if;
	end if;
    end for;
    return p;    
end function;

function dim_threetors_overnfield(definingpols,n,expectedorderofGal : notnormal := false, minusoneinGal := true);
    C := HyperellipticCurveOfGenus(2,definingpols[1]+definingpols[2]^2/4);
    f := HyperellipticPolynomials(C);
    coeffs := Coefficients(f);
    lencoeffs := #coeffs;
    coeffs := coeffs cat [0 : i in [7-lencoeffs]];
    Jac := Jacobian(C);
    Kum := KummerSurface(Jac);
    zeropt := Kum ! 0;
    hompols, affpols := eqns_2PequalsnegativeP(Rationals(),definingpols);

    A16<k1,k2,k3,k4,f0,f1,f2,f3,f4,f5,f6,alpha,l1,l2,l3,l4> := PolynomialRing(RationalField(),16);
    A5<k1,k2,k3,k4,alpha> := PolynomialRing(Rationals(),5);
    projec1 := hom<A16 -> A5 | [A5.i : i in [1..4]] cat [0 : i in [1..7]] cat [A5.5] cat [0 : i in [1..4]]>;
    A4<K1,K2,K3,K4> := PolynomialRing(Rationals(),4);
    projec2 := hom<A5 -> A4 | [A4.i : i in [1..4]] cat [0]>;
    temppols1 := [projec1(hompols[1])] cat [Resultant(projec1(hompols[j-1]), projec1(hompols[j]), alpha) : j in [3..#hompols]];
    temppols2 := [projec2(temppols1[j]) : j in [1..#temppols1]];
    P3 := ProjectiveSpace(Rationals(),3);
    X := Scheme(P3,temppols2);


    P<x> := Parent(f);
    newf, twistbyd := modifying_goodsexticpoly(f);
    atoe := [Coefficient(newf,4-i) : i in [0..4]];
    if atoe[2] eq 0 and atoe[4] eq 0 then
	newf := P ! ((x+1)^6*Evaluate(newf,x/(x+1)));
	newf, twistbyd1 := modifying_goodsexticpoly(newf);
	twistbyd *:= twistbyd1;
	atoe := [Coefficient(newf,4-i) : i in [0..4]];
    end if;
    lcmofdens := LCM([Denominator(atoe[i]) : i in [1..#atoe]]);
    fulltp := torspoly_part1(Rationals(), atoe) + torspoly_part2(Rationals(), atoe);
    if not IsSeparable(fulltp) then
//	"Not separable";
	for a in [1..5] do
	for b in [1..5] do
	for c in [1..5] do
	for d in [1..5] do
	    if a*d-b*c ne 0 then
		newf := P ! ((c*x+d)^6*Evaluate(newf,(a*x+b)/(c*x+d)));
		newf, twistbyd2 := modifying_goodsexticpoly(newf);
		twistbyd *:= twistbyd2;
		atoe := [Coefficient(newf,4-i) : i in [0..4]];
		lcmofdens := LCM([Denominator(atoe[i]) : i in [1..#atoe]]);
		fulltp := torspoly_part1(Rationals(), atoe) + torspoly_part2(Rationals(), atoe);
		if IsSeparable(fulltp) then
//		    "Separable";
		    break a;
		end if;
	    end if;
	end for;
	end for;
	end for;
	end for;
    end if;

    if not IsSquare(twistbyd) then
	ff := fulltp;
	gg := P ! [Coefficient(ff,2*i) : i in [0..Degree(ff)/2]];
	ggnew := P ! [Coefficient(gg,i)*twistbyd^(Degree(gg)-i) : i in [0..Degree(gg)]];
	ffnew := Evaluate(ggnew,x^2);
    else
	ffnew := fulltp;
	ggnew := P ! [Coefficient(ffnew,2*i) : i in [0..Degree(ffnew)/2]];
    end if;


    Fac := Factorisation(ffnew);
    Facproj := Factorisation(ggnew);

    if minusoneinGal then
	Ga, Ra, Sa := GaloisGroup(Fac[#Fac][1]);
	if #Ga ne expectedorderofGal then
	    Ga, Ra, Sa := GaloisGroup(ffnew);
	end if;
    else
	Ga, Ra, Sa := GaloisGroup(Facproj[#Facproj][1]);
	if #Ga ne expectedorderofGal then
	    Ga, Ra, Sa := GaloisGroup(ggnew);
	end if;
    end if;

    indexnsubs := Subgroups(Ga : IndexEqual := n);
    nsubfields := [GaloisSubgroup(Sa,indexnsub`subgroup) : indexnsub in indexnsubs];
    nirredsubfields := [nsubfield : nsubfield in nsubfields | IsIrreducible(nsubfield)];

    max_dim := dim_rationalthreetors(definingpols);
    nfieldK := RationalField();
    for temp in nirredsubfields do
	L := NumberField(temp);
	JacL := BaseExtend(Jac,L);
	KumL := BaseExtend(Kum,L);
	zeroptL := KumL ! 0;
	XptsL := RationalPoints(X,L);
	count := 0;
	for Xpt in XptsL do
	    kumpt := KumL ! Eltseq(Xpt);
	    if 3*kumpt eq zeroptL then
		possible_points := Points(JacL, kumpt);
//		print #possible_points;
		count := count + #possible_points;
	    end if;
	end for;

//	print count;
	if notnormal then
	    if not IsNormal(NumberField(monicintegralpol(DefiningPolynomial(L)))) and Valuation(count,3) ge max_dim then
		max_dim := Valuation(count,3);
		nfieldK := L;
//		print max_dim, nfieldK;
	    end if;
	else
	    if Valuation(count,3) ge max_dim then
		max_dim := Valuation(count,3);
		nfieldK := L;
	    end if;
	end if;
    end for;
    return max_dim, nfieldK;
end function;


function projthreetorsGal(defpols,projimageorder);
    f := defpols[1]+defpols[2]^2/4;
    P<x> := Parent(f);
    newf, twistbyd := modifying_goodsexticpoly(f);
    atoe := [Coefficient(newf,4-i) : i in [0..4]];
    if atoe[2] eq 0 and atoe[4] eq 0 then
	newf := P ! ((x+1)^6*Evaluate(newf,x/(x+1)));
	newf, twistbyd1 := modifying_goodsexticpoly(newf);
	twistbyd *:= twistbyd1;
	atoe := [Coefficient(newf,4-i) : i in [0..4]];
    end if;
    lcmofdens := LCM([Denominator(atoe[i]) : i in [1..#atoe]]);
    fulltp := torspoly_part1(Rationals(), atoe) + torspoly_part2(Rationals(), atoe);

    if not IsSeparable(fulltp) then
//	"Not separable";
	for a in [1..5] do
	for b in [1..5] do
	for c in [1..5] do
	for d in [1..5] do
	    if a*d-b*c ne 0 then
		newf := P ! ((c*x+d)^6*Evaluate(newf,(a*x+b)/(c*x+d)));
		newf, twistbyd2 := modifying_goodsexticpoly(newf);
		twistbyd *:= twistbyd2;
		atoe := [Coefficient(newf,4-i) : i in [0..4]];
		lcmofdens := LCM([Denominator(atoe[i]) : i in [1..#atoe]]);
		fulltp := torspoly_part1(Rationals(), atoe) + torspoly_part2(Rationals(), atoe);
		if IsSeparable(fulltp) then
//		    "Separable";
		    break a;
		end if;
	    end if;
	end for;
	end for;
	end for;
	end for;
    end if;

    if not IsSquare(twistbyd) then
	ff := fulltp;
	gg := P ! [Coefficient(ff,2*i) : i in [0..Degree(ff)/2]];
	ggnew := P ! [Coefficient(gg,i)*twistbyd^(Degree(gg)-i) : i in [0..Degree(gg)]];
	ffnew := Evaluate(ggnew,x^2);
    else
	ffnew := fulltp;
	ggnew := P ! [Coefficient(ffnew,2*i) : i in [0..Degree(ffnew)/2]];
    end if;
    Facproj := Factorisation(ggnew);
    Ga := GaloisGroup(Facproj[#Facproj][1] : Type := "Complex");
    if #Ga eq projimageorder then
	return IdentifyGroup(Ga);
    else
	poly := Facproj[#Facproj][1];
	P2<t,u> := PolynomialRing(Rationals(),2);
	for j := #Facproj-1 to 1 by -1 do
	    newfac := Facproj[j][1];
	    poly := Resultant(Evaluate(poly,t),Evaluate(newfac,u-t),t);
	    poly := P ! UnivariatePolynomial(poly);
	    if IsIrreducible(poly) then
		Ga := GaloisGroup(poly : Type := "Complex");
		if #Ga eq projimageorder then
		    return IdentifyGroup(Ga);
		end if;
	    elif projimageorder le 36 then
		Ga := GaloisGroup(poly);
		if #Ga eq projimageorder then
		    return IdentifyGroup(Ga);
		end if;
	    end if;
	end for;
    end if;
end function;


// ##########################################################################################################
// further global tests based on the maximum number of three-torsion points over small degree number fields.
// to distinguish among the multiple possibilities outputted by the signature test.

function max_pts_over_ext(H,n : normal := false);
    ZH := Subgroups(H);
    MH := GModule(H);
    if not normal then
	max_pts := 0;
	ordH := #H;
	for i := 1 to #ZH do
	    K := ZH[i]`subgroup;
	    if ordH/#K eq n then
		max_pts := Maximum(max_pts,Dimension(FixMod(MH,K)));
	    end if;
	end for;
	return max_pts;
    else
	max_pts := 0;
	ordH := #H;
	for i := 1 to #ZH do
	    K := ZH[i]`subgroup;
	    if ordH/#K eq n and IsNormal(H,K) then
		max_pts := Maximum(max_pts,Dimension(FixMod(MH,K)));
	    end if;
	end for;
	return max_pts;
    end if;
end function;

function final_test(poss);
    if #poss eq 3 then
	ii := poss[1][1];
	jj := poss[2][1];
	kk := poss[3][1];
	H1 := ZG[ii]`subgroup;
	H2 := ZG[jj]`subgroup;
	H3 := ZG[kk]`subgroup;
	for n := 1 to Maximum([#H1,#H2,#H3]) do
	    tempset := {max_pts_over_ext(H1,n),max_pts_over_ext(H2,n),max_pts_over_ext(H3,n)};
	    if #tempset eq 3 then
		return n;
	    end if;
	end for;
	return -3;
    elif #poss eq 4 then
	ii := poss[1][1];
	jj := poss[2][1];
	kk := poss[3][1];
	ll := poss[4][1];
	H1 := ZG[ii]`subgroup;
	H2 := ZG[jj]`subgroup;
	H3 := ZG[kk]`subgroup;
	H4 := ZG[ll]`subgroup;
	for n := 1 to Maximum([#H1,#H2,#H3,#H4]) do
	    tempset := {max_pts_over_ext(H1,n),max_pts_over_ext(H2,n),max_pts_over_ext(H3,n),max_pts_over_ext(H4,n)};
	    if #tempset eq 4 then
		return n;
	    end if;
	end for;
	return -4;
    end if;
    ii := poss[1][1];
    jj := poss[2][1];
    H1 := ZG[ii]`subgroup;
    H2 := ZG[jj]`subgroup;
    for n := 1 to Maximum(#H1,#H2) do
	if max_pts_over_ext(H1,n) ne max_pts_over_ext(H2,n) then
	    return n;
	end if;
    end for;
/*
    print "Test failure: For any given degree, the maximum number of three 
torsion points over a number field of that degree is the same.";
*/
    return -1;
end function;

function distinguish(defpols, poss);
    if #poss eq 3 then
	dimtors := dim_rationalthreetors(defpols);
	for i := 1 to #poss do
	    if max_pts_over_ext(ZG[poss[i][1]]`subgroup,1) eq dimtors then
		return poss[i], [ZG[poss[i][j]]`subgroup : j in [1..#poss[i]]];
	    end if;
	end for;
    elif #poss eq 4 then
	if ZG[poss[1][1]]`order eq 324 then
	    possreordered := poss;
	    for i := 1 to #poss do
		if max_pts_over_ext(ZG[poss[i][1]]`subgroup,1) eq 1 then
		    possreordered[1] := poss[i];
		elif max_pts_over_ext(ZG[poss[i][1]]`subgroup,3) eq 1 then
		    possreordered[2] := poss[i];
		elif Dimension(FixMod(GModule(ZG[poss[i][1]]`subgroup),SG meet ZG[poss[i][1]]`subgroup)) eq 1 then
		    possreordered[3] := poss[i];
		else
		    possreordered[4] := poss[i];
		end if;
	    end for;
	    if dim_rationalthreetors(defpols) eq 1 then
		return possreordered[1], [ZG[possreordered[1][j]]`subgroup : j in [1..#possreordered[1]]];
	    elif dim_threetors_overnfield(defpols,3,324 : minusoneinGal := false) eq 1 then
		return possreordered[2], [ZG[possreordered[2][j]]`subgroup : j in [1..#possreordered[2]]];
	    elif dim_cyclotomicthreetors(defpols) eq 1 then
		return possreordered[3], [ZG[possreordered[3][j]]`subgroup : j in [1..#possreordered[3]]];
	    else
		return possreordered[4], [ZG[possreordered[4][j]]`subgroup : j in [1..#possreordered[4]]];
	    end if;
	elif ZG[poss[1][1]]`order eq 162 then
	    possreordered := poss;
	    for i := 1 to #poss do
		if max_pts_over_ext(ZG[poss[i][1]]`subgroup,1) eq 1 then
		    if IdentifyGroup(ZG[poss[i][1]]`subgroup) eq <162,19> then
			possreordered[1] := poss[i];
		    elif IdentifyGroup(ZG[poss[i][1]]`subgroup) eq <162,11> then
			possreordered[2] := poss[i];
		    end if;
		else
		    if IdentifyGroup(ZG[poss[i][1]]`subgroup) eq <162,19> then
			possreordered[3] := poss[i];
		    elif IdentifyGroup(ZG[poss[i][1]]`subgroup) eq <162,11> then
			possreordered[4] := poss[i];
		    end if;
		end if;
	    end for;
	    if dim_rationalthreetors(defpols) eq 1 then
		idGal := projthreetorsGal(defpols,162);
		if idGal eq <162,19> then
		    return possreordered[1], [ZG[possreordered[1][j]]`subgroup : j in [1..#possreordered[1]]];
		elif idGal eq <162,11> then
		    return possreordered[2], [ZG[possreordered[2][j]]`subgroup : j in [1..#possreordered[2]]];
		end if;
	    else
		idGal := projthreetorsGal(defpols,162);
		if idGal eq <162,19> then
		    return possreordered[3], [ZG[possreordered[3][j]]`subgroup : j in [1..#possreordered[3]]];
		elif idGal eq <162,11> then
		    return possreordered[4], [ZG[possreordered[4][j]]`subgroup : j in [1..#possreordered[4]]];
		end if;
	    end if;
	end if;
    elif #poss eq 2 then
	n := final_test(poss);
	if (n eq -1) or (n eq 6) or (n eq 8 and ZG[poss[1][1]]`order eq 32) then
	    idGal := projthreetorsGal(defpols,ZG[poss[1][1]]`order/2);
	    minusone := Center(G).1;
	    for i := 1 to #poss do
		if IdentifyGroup(quo<ZG[poss[i][1]]`subgroup|minusone>) eq idGal then
		    return poss[i], [ZG[poss[i][j]]`subgroup : j in [1..#poss[i]]];
		end if;
	    end for;
	elif n eq 1 then
	    dimtors := dim_rationalthreetors(defpols);
	    for i := 1 to #poss do
		if max_pts_over_ext(ZG[poss[i][1]]`subgroup,n) eq dimtors then
		    return poss[i], [ZG[poss[i][j]]`subgroup : j in [1..#poss[i]]];
		end if;
	    end for;
	elif n eq 2 then
	    dimtors := dim_threetors_overnfield(defpols,n,ZG[poss[1][1]]`order);
	    for i := 1 to #poss do
		if max_pts_over_ext(ZG[poss[i][1]]`subgroup,n) eq dimtors then
		    return poss[i], [ZG[poss[i][j]]`subgroup : j in [1..#poss[i]]];
		end if;
	    end for;
	elif n eq 3 then
	    dimtors := dim_threetors_overnfield(defpols,n,ZG[poss[1][1]]`order : minusoneinGal := false);
	    for i := 1 to #poss do
		if max_pts_over_ext(ZG[poss[i][1]]`subgroup,n) eq dimtors then
		    return poss[i], [ZG[poss[i][j]]`subgroup : j in [1..#poss[i]]];
		end if;
	    end for;
	else
	    dimtors := dim_threetors_overnfield(defpols,4,ZG[poss[1][1]]`order : notnormal := true, minusoneinGal := false);
	    Hcand := ZG[poss[1][1]]`subgroup;
	    Mcand := GModule(Hcand);
	    ZHcand := [Kind`subgroup : Kind in Subgroups(Hcand) | Kind`order eq #Hcand/4];
	    boo := false;
	    for Kcand in ZHcand do
		if Dimension(FixMod(Mcand,Kcand)) eq 1 and not IsNormal(Hcand,Kcand) then
		    boo := true;
		    break;
		end if;
	    end for;
	    if (boo and dimtors eq 1) or (not boo and dimtors eq 0) then
		return poss[1], [ZG[poss[1][j]]`subgroup : j in [1..#poss[1]]];
	    else
		return poss[2], [ZG[poss[2][j]]`subgroup : j in [1..#poss[2]]];
	    end if;
	end if;
    end if;
end function;


// ###########################################################################################################

function find3torsimage(cond,definingpols : primesstart := 3, primesend := 500, list_of_counts := [0/1 : i in [1..18]]);
    C := HyperellipticCurveOfGenus(2,definingpols);
    for N := primesstart to primesend do
	p := NthPrime(N);
	if cond mod p ne 0 then
	    Cp := ChangeRing(C,GF(p));
	    Jp := Jacobian(Cp);
	    ordJp := Order(Jp: UseGenus2 := true);
	    if ordJp mod 9 ne 0 then
		n := Valuation(ordJp,3);
	    else
		A3 := Sylow(Jp,3);
		A3mod3A3 := quo<A3|3*A3>;
		n := Valuation(#A3mod3A3,3);
	    end if;

	    traceoffrobp := (1 + p - #Cp) mod 3;
	    sigp := <[p mod 3, traceoffrobp], n>;
	    iii := Index(sigs,sigp);
	    list_of_counts[iii] := list_of_counts[iii]+1;
	end if;
/*
	if N mod 100 eq 0 then
	    print N;
	end if;
*/
    end for;
    totalprimes := &+list_of_counts;
    freqstat := [list_of_counts[i]/totalprimes : i in [1..#list_of_counts]];
    sigsshowingup := allvalidsigs(freqstat);

/*
    if #sigsshowingup eq 2 then
	return subs_with_sigstat[211][1], ZG[subs_with_sigstat[211][1][1]]`order;
    elif #sigsshowingup eq 16 then
	return subs_with_sigstat[7][1], ZG[subs_with_sigstat[7][1][1]]`order;
    elif #sigsshowingup eq 17 then
	return subs_with_sigstat[3][1], ZG[subs_with_sigstat[3][1][1]]`order;
    elif #sigsshowingup eq 18 then
	return subs_with_sigstat[1][1], ZG[subs_with_sigstat[1][1][1]]`order;
    end if;
*/

    if #sigsshowingup eq 18 or (#sigsshowingup eq 17 and not 1 in sigsshowingup) then
	return subs_with_sigstat[1][1], ZG[subs_with_sigstat[1][1][1]]`subgroup;
    end if;

    V := VectorSpace(RealField(),18);
    possibilities := [];
    errors := [];
    for i := 1 to #all_sigstats do
	sigstatH := all_sigstats[i];
	sigH := allvalidsigs(sigstatH);
	if Set(sigsshowingup) subset Set(sigH) then
	    err := V ! sigstatH - V ! freqstat;
//	    print i, sigH, Norm(err);
	    if Norm(err) lt allmindists[i] then
		Append(~possibilities,subs_with_sigstat[i]);
		Append(~errors,Norm(err));
	    end if;
	end if;
    end for;

    if #possibilities ne 1 then
//	print "More primes need to be sampled. Sampling more primes...";
	newprimesstart := primesend + 1;
	newprimesend := primesend + 300;
	return find3torsimage(cond, definingpols : primesstart := newprimesstart, primesend := newprimesend, list_of_counts := list_of_counts);
    elif #possibilities[1] gt 1 then
//	print "Sampled data about frobenius cannot distinguish the image upto GL conjugacy uniquely.";
//	print "The image could be a subgroup of one of the following index:";
//	print possibilities[1], final_test(possibilities[1]);
//	print "Looking at global data to distinguish between the", #possibilities[1], "possible images...";
	return distinguish(definingpols,possibilities[1]);
    else
	return possibilities[1][1], [ZG[possibilities[1][1][j]]`subgroup : j in [1..#possibilities[1][1]]];
    end if;
end function;


// ###########################################################################################################


function conjugacyindex(H);
    for i := 1 to #ZG do
	if IsConjugate(G,ZG[i]`subgroup,H) then
	    return i;
	end if;
    end for;
end function;

function elmtsfromeachcc(H);
    return [#(Set(H) meet Orbit(G,CC[i][3]))/#H : i in [1..#CC]];
end function;

function elmtconjugacyindex(g);
    assert exists(i){i : i in [1..#CC] | IsConjugate(G,CC[i][3],g)};
    return i;
end function;

function allvalidccs(ccstat);
    validccs := [];
    for i := 1 to #ccstat do
	if ccstat[i] ne 0 then
	    Append(~validccs,i);
	end if;
    end for;
    return validccs;
end function;

function symplecticbasis(fourpoints);
    P1 := fourpoints[1];
    for pt in fourpoints do
	temp := WeilPairing(P1,pt,3);
	if temp ne 1 then
	    P4 := pt;
	    zeta3 := temp;
	    break;
	end if;
    end for;
    remainingpoints := Exclude(Exclude(fourpoints,P1),P4);
    m := AssociativeArray();
    m[zeta3] := 1; m[zeta3^2] := 2; m[zeta3^3] := 0;
    P2 := remainingpoints[1];
    P3 := remainingpoints[2];
    P2 := P2 + m[WeilPairing(P4,P2,3)]*P1 - m[WeilPairing(P1,P2,3)]*P4;
    P3 := m[WeilPairing(P2,P3,3)]*P3;
    P3 := P3 + m[WeilPairing(P4,P3,3)]*P1 - m[WeilPairing(P1,P3,3)]*P4;
    sympbasis := [P1, P2, P3, P4];
    pairingsmat := Matrix(GF(3),4,4,[[m[WeilPairing(x,y,3)] : y in sympbasis] : x in sympbasis]);
    J := StandardAlternatingForm(4,3);
    assert pairingsmat eq J;
    return sympbasis;
end function;

function seconddistinguish(defpols, poss);
    C := HyperellipticCurveOfGenus(2,defpols);
    C1 := SimplifiedModel(C);
    Jac := Jacobian(C);
    JacC1 := Jacobian(C1);
    badprimes := &*BadPrimes(C)*2;
    p := 4;
    ccs1 := allvalidccs(elmtsfromeachcc(ZG[poss[1]]`subgroup));
    ccs2 := allvalidccs(elmtsfromeachcc(ZG[poss[2]]`subgroup));
    while true do
	p := NextPrime(p);
	if badprimes mod p ne 0 then
	    kp3 := GF(p,3);
	    Jackp3 := BaseExtend(JacC1,kp3);
	    A, phi := AbelianGroup(Jackp3);
	    if #quo<A|3*A> eq 81 then
		Pred<x> := PolynomialRing(kp3);
		ords := [Order(A.i) : i in [1..4]];
		basis := [phi(ExactQuotient(ords[i],3)*A.i) : i in [1..4]];
		sympbasis := symplecticbasis(basis);
		sigmabasis := [];
		for i := 1 to #basis do
		    Pi := sympbasis[i];
		    sigmai1 := Pred ! [Frobenius(coe) : coe in Coefficients(Pi[1])];
		    sigmai2 := Pred ! [Frobenius(coe) : coe in Coefficients(Pi[2])];
		    sigmaPi := elt<Jackp3 | sigmai1, sigmai2, Pi[3]>;
		    Append(~sigmabasis,sigmaPi);
		end for;
		all_pts_k := [];
		coords := [];
		for i1 := 0 to 2 do
		for i2 := 0 to 2 do
		for i3 := 0 to 2 do
		for i4 := 0 to 2 do
		    po := i1*sympbasis[1] + i2*sympbasis[2] + i3*sympbasis[3] + i4*sympbasis[4];
		    Append(~all_pts_k,po);
		    Append(~coords,[i1, i2, i3, i4]);
		end for;
		end for;
		end for;
		end for;
		sigmabasiscoords := [coords[Index(all_pts_k,sigmabasis[i])] : i in [1..#sigmabasis]];
		frobpmat := G ! Matrix(GF(3),4,4,sigmabasiscoords);
		indi := elmtconjugacyindex(frobpmat);
		if Order(frobpmat) eq 3 and indi in ccs1 then
		    return poss[1], ZG[poss[1]]`subgroup;
		elif Order(frobpmat) eq 3 and indi in ccs2 then
		    return poss[2], ZG[poss[2]]`subgroup;
		end if;
	    end if;
	end if;
    end while;
end function;


function threetorsfield(defpols, n : ignoretwists := false);
    f := defpols[1]+defpols[2]^2/4;
    P<x> := Parent(f);
    newf, twistbyd := modifying_goodsexticpoly(f);
    atoe := [Coefficient(newf,4-i) : i in [0..4]];
    if atoe[2] eq 0 and atoe[4] eq 0 then
	newf := P ! ((x+1)^6*Evaluate(newf,x/(x+1)));
	newf, twistbyd1 := modifying_goodsexticpoly(newf);
	twistbyd *:= twistbyd1;
	atoe := [Coefficient(newf,4-i) : i in [0..4]];
    end if;
    lcmofdens := LCM([Denominator(atoe[i]) : i in [1..#atoe]]);
    fulltp := torspoly_part1(Rationals(), atoe) + torspoly_part2(Rationals(), atoe);
    if not IsSeparable(fulltp) then
//	"Not separable";
	for a in [1..5] do
	for b in [1..5] do
	for c in [1..5] do
	for d in [1..5] do
	    if a*d-b*c ne 0 then
		newf := P ! ((c*x+d)^6*Evaluate(newf,(a*x+b)/(c*x+d)));
		newf, twistbyd2 := modifying_goodsexticpoly(newf);
		twistbyd *:= twistbyd2;
		atoe := [Coefficient(newf,4-i) : i in [0..4]];
		lcmofdens := LCM([Denominator(atoe[i]) : i in [1..#atoe]]);
		fulltp := torspoly_part1(Rationals(), atoe) + torspoly_part2(Rationals(), atoe);
		if IsSeparable(fulltp) then
//		    "Separable";
		    break a;
		end if;
	    end if;
	end for;
	end for;
	end for;
	end for;
    end if;
    Fac := Factorisation(fulltp);
    if ignoretwists then
	K := SplittingField(Fac[#Fac][1]);
    else
	ff := Fac[#Fac][1];
	gg := P ! [Coefficient(ff,2*i) : i in [0..Degree(ff)/2]];
	ggnew := P ! [Coefficient(gg,i)*twistbyd^(Degree(gg)-i) : i in [0..Degree(gg)]];
	ffnew := Evaluate(ggnew,x^2);
	K := SplittingField(ffnew);
    end if;
    if Degree(K) eq n or Degree(K) eq 2*n then
	return K, lcmofdens;
    else
	for g in [fa[1] : fa in Fac[1..#Fac-1] | Degree(fa[1]) ne 1] do
	    newfacs := Factorisation(ChangeRing(g,K));
	    if #newfacs ne Degree(g) then
		K := SplittingField(&*[h[1] : h in newfacs | Degree(h[1]) ne 1]);
		K := AbsoluteField(K);
		if Degree(K) eq n or Degree(K) eq 2*n then
		    break;
		end if;
	    end if;
 	end for;
    end if;
    return K, lcmofdens;
end function;


function thirddistinguish(defpols, poss);
    C := HyperellipticCurveOfGenus(2,defpols);
    C1 := SimplifiedModel(C);
    badprimes := &*BadPrimes(C1)*2;
    P<x> := PolynomialRing(Rationals());
    K, lcmofdens := threetorsfield(defpols, ZG[poss[1]]`order);
    Jac := Jacobian(C1);
    JacK := BaseExtend(Jac,K);
    KumK := KummerSurface(JacK);
    zeropt := KumK ! 0;

    f := HyperellipticPolynomials(C1);
    hompols, affpols := eqns_2PequalsnegativeP(Rationals(),[f,0]);
    A16<k1,k2,k3,k4,f0,f1,f2,f3,f4,f5,f6,alpha,l1,l2,l3,l4> := PolynomialRing(RationalField(),16);
    A5<k1,k2,k3,k4,alpha> := PolynomialRing(Rationals(),5);
    projec1 := hom<A16 -> A5 | [A5.i : i in [1..4]] cat [0 : i in [1..7]] cat [A5.5] cat [0 : i in [1..4]]>;
    A4<K1,K2,K3,K4> := PolynomialRing(Rationals(),4);
    projec2 := hom<A5 -> A4 | [A4.i : i in [1..4]] cat [0]>;
    temppols1 := [projec1(hompols[1])] cat [Resultant(projec1(hompols[j-1]), projec1(hompols[j]), alpha) : j in [2..#hompols]];
    temppols2 := [projec2(temppols1[j]) : j in [1..#temppols1]];

    P3 := ProjectiveSpace(K,3);
    X := Scheme(P3,temppols2);
    Xpts := RationalPoints(X);
    all_pts := [];
    count := 0;
    for Xpt in Xpts do
	kumpt := KumK ! Eltseq(Xpt);
	if 3*kumpt eq zeropt then
	    possible_points := Points(JacK, kumpt);
	    count +:= #possible_points;
	    all_pts := all_pts cat SetToSequence(possible_points);
	end if;
    end for;

    if #all_pts ne 81 then
	print "Did not find the correct three torsion field to distinguish 
between the possibilities", [GSpLookupLabel(X,ZG[ps]`subgroup) : ps in poss];
	return 0, "Error";
    end if;

    defK := DefiningPolynomial(K);
    dens := 1;
    for i := 1 to #all_pts do
	if all_pts[i] ne JacK ! 0 then
	    dens1 := LCM([LCM([Denominator(coe[j]) : j in [1..Degree(K)]]) : coe in Coefficients(all_pts[i][1])]);
	    dens2 := LCM([LCM([Denominator(coe[j]) : j in [1..Degree(K)]]) : coe in Coefficients(all_pts[i][2])]);
	    dens := LCM([dens,dens1,dens2]);
	end if;
    end for;

/* Fixing a symplectic basis */

    basisfound := false;
    p := 4;
    while not basisfound do
	p := NextPrime(p);
	if badprimes mod p ne 0 and lcmofdens mod p ne 0 and dens mod p ne 0 then
	    k := SplittingField(ChangeRing(defK,GF(p)));
	    Roos := Roots(defK,k);
	    alp := Roos[1][1];
	    Jack := BaseExtend(JacK,k);
	    all_pts_k := [];
	    Pred<x> := PolynomialRing(k);
	    for i := 1 to #all_pts do
		pt1 := Coefficients(all_pts[i][1]);
		pt2 := Coefficients(all_pts[i][2]);
		pt3 := all_pts[i][3];
		pt1red := Pred ! [&+[coe[j]*alp^(j-1) : j in [1..Degree(K)]] : coe in pt1];
		pt2red := Pred ! [&+[coe[j]*alp^(j-1) : j in [1..Degree(K)] ] : coe in pt2];
		reducedpt := elt<Jack | [pt1red,pt2red]>;
		Append(~all_pts_k,reducedpt);
	    end for;

	    for i := 1 to #all_pts_k do
		P1 := all_pts_k[i];
		if P1 ne Jack ! 0 then
		    for j := 1 to #all_pts_k do
			P4 := all_pts_k[j];
			zeta3 := WeilPairing(P1,P4,3);
			if zeta3 ne 1 then
			    for i2 := 1 to #all_pts_k do
				P2 := all_pts_k[i2];	
				if WeilPairing(P1,P2,3) eq 1 and WeilPairing(P4,P2,3) eq 1 then
				    for j2 := 1 to #all_pts_k do
					P3 := all_pts_k[j2];
					if WeilPairing(P1,P3,3) eq 1 and WeilPairing(P4,P3,3) eq 1 and WeilPairing(P2,P3,3) eq zeta3 then
					    basisfound := true;
					    break i;
					end if;
				    end for;
				end if;
			    end for;
			end if;
		    end for;
		end if;
	    end for;

	    if basisfound then
		basismodp := [P1, P2, P3, P4];
		basisindices := [Index(all_pts_k,basismodp[i]) : i in [1..#basismodp]];
		basis := [all_pts[basisindices[i]] : i in [1..#basisindices]];
	    end if;
	end if;
    end while;

/* Computing frobenius images for several primes with respect to the fixed basis
and deducing the three-torsion Galois image. */

    torsimage := sub<G | Identity(G)>;
    while true do
	basisk := basismodp;
	all_pts_k := [];
	coords := [];
	for i1 := 0 to 2 do
	    for i2 := 0 to 2 do
		for i3 := 0 to 2 do
		    for i4 := 0 to 2 do
			po := i1*basisk[1] + i2*basisk[2] + i3*basisk[3] + i4*basisk[4];
			Append(~all_pts_k,po);
			Append(~coords,[i1, i2, i3, i4]);
		    end for;
		end for;
	    end for;
	end for;

	sigmabasis := [];
	for i := 1 to #basisk do
	    Pi := basisk[i];
	    sigmai1 := Pred ! [Frobenius(coe) : coe in Coefficients(Pi[1])];
	    sigmai2 := Pred ! [Frobenius(coe) : coe in Coefficients(Pi[2])];
	    sigmai3 := Pi[3];
	    sigmaPi := elt<Jack | sigmai1, sigmai2, sigmai3>;
	    Append(~sigmabasis,sigmaPi);
	end for;

	sigmabasiscoords := [coords[Index(all_pts_k,sigmabasis[i])] : i in [1..#sigmabasis]];
	frobpmat := G ! Matrix(GF(3),4,4,sigmabasiscoords);
	torsimage := sub<G | torsimage, frobpmat>;
	n := conjugacyindex(torsimage);
	if n in poss then
	    return n, ZG[n]`subgroup;
	end if;

	p := NextPrime(p);
	while dens mod p eq 0 do
	    p := NextPrime(p);
	end while;
	k := SplittingField(ChangeRing(defK,GF(p)));
	Roos := Roots(defK,k);
	alp := Roos[1][1];
	Pred<x> := PolynomialRing(k);
	Jack := BaseExtend(JacK,k);
	basismodp := [];
	for i := 1 to #basis do
	    pt1 := Coefficients(basis[i][1]);
	    pt2 := Coefficients(basis[i][2]);
	    pt3 := basis[i][3];
	    pt1red := Pred ! [&+[k ! (coe[j])*alp^(j-1) : j in [1..Degree(K)]] : coe in pt1];
	    pt2red := Pred ! [&+[k ! (coe[j])*alp^(j-1) : j in [1..Degree(K)] ] : coe in pt2];
	    reducedpt := elt<Jack | [pt1red,pt2red]>;
	    Append(~basismodp,reducedpt);
	end for;
    end while;
end function;


function threetorsimage(C : primesbound := 500);
    cond := &*BadPrimes(C)*2;
    f,h := HyperellipticPolynomials(C);
    defpols := [f,h];
    possibilities, possiblesubgroups := find3torsimage(cond, defpols : primesend := primesbound);
    if #possibilities eq 1 then
	torsimg := ZG[possibilities[1]]`subgroup;
	torsimglabel := GSpLookupLabel(X,torsimg);
	return torsimglabel, X[torsimglabel]`subgroup;
    elif #possibilities eq 3 or PrimeFactors(ZG[possibilities[1]]`order) eq [2] then
	torsimgind, torsimg := thirddistinguish(defpols, possibilities);
	torsimglabel := GSpLookupLabel(X,torsimg);
	return torsimglabel, X[torsimglabel]`subgroup;
    else
	torsimgind, torsimg := seconddistinguish(defpols, possibilities);
	torsimglabel := GSpLookupLabel(X,torsimg);
	return torsimglabel, X[torsimglabel]`subgroup;
    end if;
end function;




