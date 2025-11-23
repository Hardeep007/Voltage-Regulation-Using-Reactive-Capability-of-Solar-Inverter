clear all
clc

ch = input('Enter the bus system no.: (6 or 9 or 14 or 26 or 30 or 57): ');
while ch ~= 6 && ch ~= 14 && ch ~= 26 && ch ~= 30 && ch ~= 57 && ch ~= 9
    fprintf('Invalid Input try again\n');
    ch = input('Enter the bus system no.: (6 or 9 or 14 or 26 or 30 or 57): ');
end
switch ch
    case 6
        data6
    case 14
        data14
    case 26
        data26
    case 30
        data30
    case 57
        data57
    case 9
        data9
end

lamda = input('Enter the load factor: ');
busdata(:,5) = busdata(:,5) * (1+lamda);
busdata(:,6) = busdata(:,6) * (1+lamda);
busdata(:,7) = busdata(:,7) * (1+lamda);
busdata(:,8) = busdata(:,8) * (1+lamda);
busdata(:,9) = busdata(:,9) * (1+lamda);
busdata(:,10) = busdata(:,10) * (1+lamda);

met = input('Enter the method for load flow (1 - GS, 2 - NR, 3 - Fast Decouple): ');
while met ~= 1 && met ~= 2 && met ~= 3
    fprintf('Invalid Input try again\n');
    met = input('Enter the method for load flow (1 - GS, 2 - NR, 3 - Fast Decouple): ');
end

switch met
    case 1
        maingauss
    case 2
        mainnewton
    case 3
        maindecouple
end

    fprintf("\nONE DONE\n");

    temp = busdata;
    Vbase = Vm;

    Pi = input('Enter the active power capacity of DG(in MW): ') * (1+lamda);

    [Vmin , minbus] = mink(Vm,3);
    Qprev(1) =  Qg(minbus(1)) - Qd(minbus(1));
    Qprev(2) =  Qg(minbus(2)) - Qd(minbus(2));
    Qprev(3) =  Qg(minbus(3)) - Qd(minbus(3));

    %when only active support of PV solar is uitlized
    busdata(minbus(1),5) = busdata(minbus(1),5) - Pi;
    busdata(minbus(2),5) = busdata(minbus(2),5) - Pi;
    busdata(minbus(3),5) = busdata(minbus(3),5) - Pi;
    switch met
        case 1
            maingauss
        case 2
            mainnewton
        case 3
            maindecouple
    end
    Vonlyp = Vm;
    fprintf("\nTWO DONE\n");    

    busdata = temp;

    %calculations of reactive support values
    busdata(minbus(1),5) = busdata(minbus(1),5) - Pi;
    busdata(minbus(2),5) = busdata(minbus(2),5) - Pi;
    busdata(minbus(3),5) = busdata(minbus(3),5) - Pi;
    busdata(minbus(1),2) = 2;
    busdata(minbus(2),2) = 2;
    busdata(minbus(3),2) = 2;
    busdata(minbus(1),3) = 1;
    busdata(minbus(2),3) = 1;
    busdata(minbus(3),3) = 1;
    busdata(minbus(1),9) = min(busdata(:,9));
    busdata(minbus(2),9) = min(busdata(:,9));
    busdata(minbus(3),9) = min(busdata(:,9));
    busdata(minbus(1),10) = max(busdata(:,10));
    busdata(minbus(2),10) = max(busdata(:,10));
    busdata(minbus(3),10) = max(busdata(:,10));

    switch met
        case 1
            maingauss
        case 2
            mainnewton
        case 3
            maindecouple
    end


    fprintf("\nTHREE DONE\n");

    Vpv = Vm;

    Qnow(1) = Qg(minbus(1)) - Qd(minbus(1));
    Qnow(2) = Qg(minbus(2)) - Qd(minbus(2));
    Qnow(3) = Qg(minbus(3)) - Qd(minbus(3));

    Qreq = Qnow - Qprev;
    fprintf("The reactive support required at bus \n%d/n is \n%.2f  (MVAr)", minbus, Qreq);


    %total capacity of solar inverter (5% more than active power capacity of panel)
    Si = 1.05 * Pi/basemva ;         %in pu

    Pinv = -(Si) : 0.1/basemva : (Si) ;
    Qinv = sqrt((Si)^2 - (Pinv).^2) ;

    Qlimit = sqrt(Si^2 - (Pi/basemva)^2) * ones(length(Pinv));


    for i = 1:3
        if Qreq(i) > (Qlimit(1)*basemva)
            Qsup(i) =Qlimit(1);
        elseif Qreq(i) < ((-1*Qlimit(1))*basemva)
            Qsup(i) = (-1*Qlimit(1));
        else
            Qsup(i) = Qreq(i);
        end
    end


    %providing both active and reactive support from PV solar inverter
    busdata = temp;
    busdata(minbus(1),5) = busdata(minbus(1),5) - Pi;
    busdata(minbus(2),5) = busdata(minbus(2),5) - Pi;
    busdata(minbus(3),5) = busdata(minbus(3),5) - Pi;
    busdata(minbus(1),6) = busdata(minbus(1),6) - Qsup(1);
    busdata(minbus(2),6) = busdata(minbus(2),6) - Qsup(2);
    busdata(minbus(3),6) = busdata(minbus(3),6) - Qsup(3);

    switch met
        case 1
            maingauss
        case 2
            mainnewton
        case 3
            maindecouple
    end

    fprintf("\nFOUR DONE\n");

    Vend = Vm;


    Qreq2(1,:) = (Qreq(1)/basemva) .* ones(1,length(Pinv));
    Qreq2(2,:) = (Qreq(2)/basemva) .* ones(1,length(Pinv));
    Qreq2(3,:) = (Qreq(3)/basemva) .* ones(1,length(Pinv));


    figure;
    hold on;
    grid on;
    h1 = plot(Pinv , Qinv ,  'b' , 'LineWidth', 2);
    h2 = plot(Pinv , -Qinv , 'b' , 'LineWidth', 2);
    h3 = plot(Pinv , Qlimit , '--' , 'LineWidth', 1 , 'Color','g');
    h4 = plot(Pinv , -Qlimit , '--' , 'LineWidth', 1 , 'Color','g');
    h5 = plot(Pinv , Qreq2(1,:) , ': ' , 'LineWidth', 2 , 'Color','r');
    h6 = plot(Pinv , Qreq2(2,:) , ': ' , 'LineWidth', 2 , 'Color','m');
    h7 = plot(Pinv , Qreq2(3,:) , ': ' , 'LineWidth', 2 , 'Color','k');
    legend([h5 , h6 , h7] ,  "Required reactive support at bus " + minbus(1) , "Required reactive support at bus " + minbus(2) , "Required reactive support at bus " + minbus(3) );
    hold off;


    figure;
    hold on;
    plot(1:ch , Vbase);
    plot(1:ch , Vonlyp);
    plot(1:ch , Vend);
    legend('Without any DG' , 'With only active support by PV solar' , 'With both active and reactive support from PV solar');
    hold off;













