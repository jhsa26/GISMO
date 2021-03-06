function occurrenceplot(c,scale,clusternum)
   
   % Private method. See ../plot for details.
   
   % Author: Michael West, Geophysical Institute, Univ. of Alaska Fairbanks
   % $Date$
   % $Revision$
   
   
   % if isempty(get(c,'LINK'))
   %     error('LINK field must be filled in input object');
   % end;
   
   % if isempty(get(c,'CORR'))
   %     error('CORR field must be filled in input object');
   % end;
   
   assert(~isempty(c.clust), 'CLUST field must be filled in input object');
   if ~isempty(c.lags)
      disp('Note: Time corrections from LAG field have not been applied to traces. Each cluster will be aligned for plotting only. Note that actual data is unaffected.');
   end;
   
   % TEST FOR NUMBER OF CLUSTERS
   assert(max(clusternum) <= max(c.clust),...
      'Exceeded maximum cluster number. There are only %d clusters in this set of traces', max(c.clust));
   
   assert(numel(clusternum) <= 10, 'The occurence plot is limited to no more than 8 clusters. Consider making two plots');
   
   
   
   
   % MAKE FIGURE
   % height = 100 + 200*numel(clusternum);
   % if height>1200
   % 	height = 1200;
   % end;
   height = 1200;
   figure('Color','w','Position',[20 20 1000 height]);
   set(gcf,'DefaultAxesFontSize',12);
   
   % GET HISTOGRAM BINS
   nmax = numel(clusternum);
   if max(c.trig)-min(c.trig) > 730
      bins = datenum(min(c.trig)):30:datenum(max(c.trig));
   elseif max(c.trig)-min(c.trig) > 14
      bins = datenum(min(c.trig)):1:datenum(max(c.trig));
   else
      bins = datenum(min(c.trig)):1/24:datenum(max(c.trig));
   end
   
   % LOOP THROUGH CLUSTERS
   for n = 1:nmax
      f = find(c,'clu',clusternum(n));
      c1 = subset(c,f);
      doplotrow(c1,n,nmax,bins,clusternum(n));
   end;
   %subplot(nmax,2,nmax*2-1);
   %binsize = bins(2)-bins(1);
   %xlabel(['bin size: ' num2str(binsize) ' days']);
   
   
   %PRINT OUT FIGURE
   set(gcf, 'paperorientation', 'portrait');
   set(gcf, 'paperposition', [.25 .25 8 10.5] );
   print(gcf, '-depsc2', 'FIG.ps')
end




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOPLOTROW
% This function plots one row of the figure

function doplotrow(c1,n,nmax,bins,nclust)
   
   
   if ~isempty(c1.lags)
      c1 = adjusttrig(c1);
   end
   
   nTraces = c1.ntraces;
   if nTraces > 50
      include = 1:round(nTraces/20):nTraces;
   else
      include = 1:1:nTraces;
   end
   
   
   % DO HISTOGRAM PLOT
   subplot('Position',[.07 .99-.094*n .42 .09]);
   T = c1.trig;
   N = histc(T,bins);
   h1 = bar(bins,N,'b');
   hold on;
   ylabel('');
   if n==nmax
      datetick('x');
   else
      set(gca,'XTickLabel',[]);
   end
   xlim([min(bins) max(bins)]);
   XLIMS = get(gca,'Xlim');
   PosX = XLIMS(1) + 0.03*(XLIMS(2)-XLIMS(1));
   YLIMS = get(gca,'Ylim');
   set(gca,'Ylim',YLIMS);  % not sure why this is necessary?
   PosY = YLIMS(2) - 0.15*(YLIMS(2)-YLIMS(1));
   text(PosX,PosY,['Cluster #' num2str(nclust)],'Color','k','FontWeight','bold');
   
   
   % DO STACK PLOT
   subplot('Position',[.5 .99-.094*n .47 .09]);
   c1 = subset(c1,include);
   Ts = 86400 * (c1.traces.firstsampletime() - c1.trig);
   Te = 86400 * (c1.traces.lastsampletime() - c1.trig); %TODO: maybe off-by 1?
   c1 = stack(c1);
   c1 = norm(c1);
   c1 = crop(c1,mean(Ts),mean(Te));
   %TODO: replace waveform usage with SeismicTrace (traces)
   w = c1.traces;
   xlim([0 w(end).duration]);
   plot(w,'Color',[.7 .7 .7],'LineWidth',.5);
   hold on;
   plot(w(end),'Color','k','LineWidth',1);
   xlim([0 w(end).duration]);
   ylabel(' '); set(gca,'YTickLabel',[]);
   title('');
   if n ~= nmax
      set(gca,'XTickLabel','');
      xlabel('');
   else
      binsize = bins(2)-bins(1);
      xlabel(['bin size: ' num2str(binsize) ' days']);
   end
   
   
   XLIMS = get(gca,'Xlim');
   PosX = XLIMS(2) - 0.03*(XLIMS(2)-XLIMS(1));
   YLIMS = get(gca,'Ylim');
   set(gca,'Ylim',YLIMS);  % not sure why this is necessary?
   PosY = YLIMS(2) - 0.15*(YLIMS(2)-YLIMS(1));
   text(PosX,PosY,[ num2str(numel(include)) ' of ' num2str(nTraces) ' traces shown'],'Color','k','FontWeight','bold','HorizontalAlignment','Right');
   
end

