
package layer;

    typedef enum {READ, WRITE} rw_t;
    
class addr_txn;
    rand bit [31:0] addr;
    rand int size;

    constraint c_size { size inside {1,2,4}; }
endclass
    
class rw_txn extends addr_txn;
    rand rw_t op;

    function void rprint();
        this.randomize();
        this.print();        
    endfunction

    function void print();
        $display("  addr=%h size=%0d", this.addr, this.size);
    endfunction
    
endclass

class addr_constraint_base;
    rand bit [31:0] addr;
    rand int size;
endclass
    
class addr_permit extends addr_constraint_base;
    constraint c_addr_permit {
        addr inside {['h00000000 : 'h0000FFFF - size]} ||
        addr inside {['h10000000 : 'h1FFFFFFF - size]};        
    }
endclass

class addr_prohibit extends addr_constraint_base;
    constraint c_addr_prohibit {
        !(addr inside {['h00000000 : 'h00000FFF - size]});
    }
endclass
    
class rw_constrained_txn extends rw_txn;
    rand addr_constraint_base cnst[$];
    rand addr_permit permit;
    rand addr_prohibit prohibit;
    
    function new();
        permit = new;
        prohibit = new;
        cnst = {permit, prohibit};
    endfunction

    constraint c_all {
        foreach(cnst[i]) {
            this.addr == cnst[i].addr;
            this.size == cnst[i].size;
        }
    }
    
endclass
    
endpackage    

module TB ();

    import layer::*;
    layer::rw_constrained_txn rw_constrained_txn;
    
    initial begin
        rw_constrained_txn = new;
        
        $display("\nFIGURE 5. Read/Write transaction using a queue of constraint container classes:");
        for (int i = 0; i < 5; i++) begin
            rw_constrained_txn.rprint();
        end
        
    end
   
endmodule
