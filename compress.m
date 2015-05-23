function [pdf1,pdfPoints1]=compress(pdf,pdfPoints)

% Deals with repeated values in pdfPoints and hence in pdf
[pdfPoints1,~,i2]= unique(pdfPoints);
if length(pdfPoints1)==length(pdfPoints),
    pdf1= pdf;
else
    for i=1:length(pdfPoints1),
        pdf1(i,:)= sum(pdf(i2==i,:),1);
    end;
end;
