%% synergy vs redundancy o info plot
function step8_synergyvsredundancy_plotcurve(kplot, Omin_plot, Omax_plot, k_min, k_cutoff, O_info_min, subj, task, p)

xq = linspace(min(kplot),max(kplot),500);
Os = interp1(kplot,Omax_plot,xq,'pchip'); Oi = interp1(kplot,Omin_plot,xq,'pchip');
ypad = 0.15*(max(Os)-min(Oi)); ylo = min(Oi)-ypad; yhi = max(Os)+ypad;
xl = min(kplot); xh = max(kplot);

figure; ax = axes; hold(ax,'on'); box(ax,'on');
fill(ax,[xl xh xh xl],[0 0 yhi yhi],[1 0.85 0.85],'EdgeColor','none','FaceAlpha',0.4);
fill(ax,[xl xh xh xl],[ylo ylo 0 0],[0.85 0.85 1],'EdgeColor','none','FaceAlpha',0.4);
yline(ax,0,'k--','LineWidth',1.2,'HandleVisibility','off');
plot(ax,xq,Os,'r-','LineWidth',2.5,'DisplayName','\Omega_{max} — redundancy');
plot(ax,xq,Oi,'b-','LineWidth',2.5,'DisplayName','\Omega_{min} — synergy');
plot(ax,k_min,O_info_min,'bv','MarkerSize',10,'MarkerFaceColor','b','HandleVisibility','off');
xline(ax,k_min,'b--','LineWidth',1.2,'HandleVisibility','off');
if ~isnan(k_cutoff); xline(ax,k_cutoff,'k--','LineWidth',1.2,'HandleVisibility','off'); end
text(ax,xl+0.3,yhi-ypad*0.6,'Redundancy','Color',[0.7 0 0],'FontAngle','italic','FontSize',9);
text(ax,xl+0.3,ylo+ypad*0.5,'Synergy',   'Color',[0 0 0.7],'FontAngle','italic','FontSize',9);
xlim(ax,[xl xh]); ylim(ax,[ylo yhi]);
xlabel(ax,'Order of interaction (k)','FontSize',11);
ylabel(ax,'O-information \Omega','FontSize',11);
title(ax,sprintf('%s | %s — %d DMD modes (damping-ordered)',subj,task,p.K_keep),'FontSize',11);
legend(ax,'Location','northwest','FontSize',9);
end
